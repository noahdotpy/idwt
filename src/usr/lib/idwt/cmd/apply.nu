#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *
use ../group.nu *
use ../lib.nu *
use ../config.nu *

let config = get_parsed_config

# TODO: Use `jc ps -fu $user` to get process list that is submitted from user
def "main apply process-killing" [] {
  print "## Applying: process killing ##"

  # process-killing:
  #   allow: # allow has priority over block in all occasions
  #     - /home/noah/.local/share/activitywatch/aw-qt
  #   allow-shas:
  #     /home/noah/.local/share/activitywatch/aw-qt: dsjd9asudeu843j # sha256sum of the file at $location
  #   block:
  #     - /home/noah
 
  let block = $config | try { get process-killing.block } | default []
  let allow = $config | try { get process-killing.allow } | default []
  let allow_shas = $config | try { get process-killing.allow-shas } | default []

  let ps_data = ps | default []
  
  mut kill_list = []
  for regex in $block {
    $kill_list = [...$kill_list ...($ps_data | get name | filter {|e| does_regex_match $e $regex})]
  }

  for regex in $allow {
    $kill_list = $kill_list | default [] | filter {|e| not (does_regex_match $e $regex)}
  }

  for location in ($allow_shas | columns) {
    let real_sha = sha256sum $location | split row '  ' | trim
    let expected_sha = sha256sum ($allow_shas | get $location) | trim
    if $real_sha == $expected_sha {
      $kill_list = $kill_list | default [] | filter {|e| $e != $location}
    }
  }

  print $kill_list

  for process in ($ps_data | where name in $kill_list) {
    try { kill --force $process.pid }
    for user in ($config | get affected-users) {
      sudo --user $user notify-send --app-name "IDWT" "Killed Process" $"Process with name `($process.name)` was killed forcefully." --urgency=critical
    }
  }
}

def "main apply delayed_rules" [] {
  print "## Applying: delayed rules ##"

  let delayed_rules = cat $delayed_rules_file | from yaml
  let current_time = ^/usr/bin/date +%s | into int

  for rule in $delayed_rules {
    if $current_time >= ($rule.time_to_apply | into int) {
        ^$idwt_bin edit ...$rule.command

        # remove this from the list
        let delayed_rules = $delayed_rules | filter {|el| $el != $rule}
        $delayed_rules | to yaml | save -f $delayed_rules_file
      }
  }
}

def "main apply block-kwin-windows" [] {
    print "## Applying: block kwin windows ##"

    let file = "/etc/xdg/kwinrulesrc"

    mut lines = ["# IDWT MANAGED: FILE WILL BE CHANGED"]

    let rules = $config | try { get block-kwin-windows } | default []
    mut rule_ids = $config | try { get block-kwin-windows} | default {} | columns

    for rule_id in $rule_ids {

      let rule = $rules | get $rule_id

      $lines = [...$lines $"[($rule_id)][$i]"]
      $lines = [...$lines $"Description=IDWT Window Blocked: id=($rule_id)"]

      if (is_property_defined $rule class) {
          $lines = [...$lines $"wmclass=($rule | get class.value)"]
          $lines = [...$lines $"wmclassmatch=(kwin_match_type_to_number ($rule | get class.match_type))"]
          if (is_property_defined ($rule | get class) whole_window_class) and ($rule | get class.whole_window_class) {
              $lines = [...$lines $"wmclasscomplete=true"]
          }
      }
      if (is_property_defined $rule title) {
          $lines = [...$lines $"title=($rule | get title.value)"]
          $lines = [...$lines $"titlematch=(kwin_match_type_to_number ($rule | get title.match_type))"]
      }
      if (is_property_defined $rule role) {
          $lines = [...$lines $"windowrole=($rule | get role.value)"]
          $lines = [...$lines $"windowrolematch=(kwin_match_type_to_number ($rule | get role.match_type))"]
      }

      # Always force minimize
      $lines = [...$lines $"minimize=true"]
      $lines = [...$lines $"minimizerule=2"]

      # Always force size to be 1x1 pixels
      $lines = [...$lines $"size=1,1"]
      $lines = [...$lines $"sizerule=2"]

      # Do not obey geometry restrictions
      $lines = [...$lines $"strictgeometryrule=2"]

      $lines = [...$lines ""]
    }

    $lines = [...$lines $"[General][$i]"]
    $lines = [...$lines $"count=($rule_ids | length)"]
    $lines = [...$lines $"rules=($rule_ids | str join ',')"]

    $lines | str join "\n" | save -f $file 
}

def "main apply flatpak-app-networking" [] {
    print "## Applying: flatpak app networking ##"

    let affected_users = $config | try { get affected-users } | default []

    
    
    for user in $affected_users {
        let flatpaks_list = if ($config | try { get flatpak-app-networking.block-otherwise } | default false) {
          # the following code takes out any app ids that are in allow
          # leaving the remaining to be blocked
          let apps = flatpak list --columns app --system --app | tail -n +1 | split row "\n" | append (ls $"/home/($user)/.local/share/flatpak/exports/bin/" | get name | each {|e| $e | path basename})
          $apps | filter {|x| not ($x in ($config | get flatpak-app-networking.allow))}
        } else { [] }

        let flatpaks_list = $flatpaks_list | append ($config | try { get flatpak-app-networking.block } | default [])

        let overrides_dir = $"/home/($user)/.local/share/flatpak/overrides"
        mkdir $overrides_dir
        for file in (ls $"($overrides_dir)") {
            let file_name = echo $file | get name | path basename
            let override_file = $"($overrides_dir)/($file_name)"
            if ((open $override_file) =~ "# IDWT_REPLACEABLE" and ($file_name in $flatpaks_list) == false) {
                chattr -i $override_file
                rm $override_file
                print $"INFO: Removed redundant flatpak override at '($override_file)'"
            }
        }
    
        for flatpak in $flatpaks_list {
            let file_contents = "# IDWT_REPLACEABLE: Remove this line if you don't want this file to be automatically overwritten at any time\n[Context]\nshared=!network;"
            let override_file = $"($overrides_dir)/($flatpak)"

            if not ($override_file | path exists) {
                echo $file_contents | save --force $override_file
            }
            if (open $override_file) =~ "# IDWT_REPLACEABLE" {
                chattr -i $override_file
                echo $file_contents | save --force $override_file
                chattr +i $override_file
                print $"INFO: Created flatpak override at '($override_file)'"
            } else {
                print $"INFO: Skipping overwriting ($override_file)"
            }
        }
    }
}

def "main apply block-sites" [] {
    print "## Applying: block sites ##"

    let sites = $config | try { get block-sites } | default []

    let policy = {URLBlocklist: ($sites)}
    let policy_file = "/etc/chromium/policies/managed/idwt-auto-managed.json"

    mkdir ($policy_file | path dirname)
    $policy | to json | save -f $policy_file
    $policy | to json | save -f ($policy_file | str replace "chromium" "brave")
    
    let hosts_file = "/etc/hosts.d/idwt-blocked.conf"

    if not ($hosts_file | path dirname | path exists) {
        mkdir ($hosts_file | path dirname)
    }

    if ($hosts_file | path exists) {
        rm $hosts_file
    }
    echo "## THIS FILE MAY BE REPLACED AT ANY TIME AUTOMATICALLY ##" | save --force $hosts_file
    print $"INFO: Saving hosts file at '($hosts_file)'"

    if not (is_property_defined $config block-sites) {
        print "INFO: No hosts listed, skipping"
        return
    }
    
    for site in $sites {
        print $"INFO: Added '($site)' to hosts file"
        echo $"\n0.0.0.0 ($site)\n" | save --append $hosts_file
    }
}

def "main apply block-networking" [] {
    print "## Applying: networking ##"

    for username in ($config | get affected-users) {
        if ($config | try { get block-networking } | default false) {
            print $"INFO: Blocking internet connection for user '($username)'"
            try { iptables -A OUTPUT -m owner --uid-owner $username -j REJECT }
            try { ip6tables -A OUTPUT -m owner --uid-owner $username -j REJECT }
        } else {
            try { iptables -D OUTPUT -m owner --uid-owner $username -j REJECT }
            try { ip6tables -D OUTPUT -m owner --uid-owner $username -j REJECT }
        }
    }
}

def "main apply" [] {
    try {main apply block-kwin-windows}
    try {main apply process-killing}
    try {main apply block-sites}
    try {main apply flatpak-app-networking}
    try {main apply block-networking}
    try {main apply delayed_rules}
}
