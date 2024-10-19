#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *
use ../group.nu *
use ../lib.nu *
use ../config.nu *

# TODO: Add documentation for commands

let config = get_parsed_config

def "main apply block-binaries" [] {
  # NOTICE: TO BE RUN AS USER
  # let banned_exec_dirs = [
  #   "/home/noah/"
  #   "/dev/"
  #   "/mnt/"
  #   "/media/"
  #   "/run/"
  #   "/tmp/"
  #   "/var/home/noah/"
  #   "/var/dev/"
  #   "/var/mnt/"
  #   "/var/media/"
  #   "/var/run/"
  #   "/var/var/"
  #   "/var/tmp/"
  # ]
  
  let banned_exec_dirs = $config | get block-binaries

  let banned_processes = ps | where $it.name =~ ($banned_exec_dirs | str join "|")

  print $banned_processes

  for process in $banned_processes {
    try { kill --force $process.pid }
    # try {notify-send --app-name "IDWT" "Killed Execution of Binary" $"Process with name `($process.name)` was killed forcefully." --urgency=critical}
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
    print "## Applying: block-kwin-windows ##"

    let file = "/etc/xdg/kwinrulesrc"

    mut lines = ["# IDWT MANAGED: FILE WILL BE CHANGED"]

    let rules = $config | get block-kwin-windows
    mut rule_ids = $config | get block-kwin-windows | columns

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
    print "## Applying: flatpak-app-networking ##"

    let affected_users = $config | try {get affected-users} | default []
    
    for user in $affected_users {
        let flatpaks_list = if (is_property_defined ($config | get flatpak-app-networking) allow-only) {
          # the following code takes out any app ids that are in allow-only
          # leaving the remaining to be blocked
          let apps = flatpak list --columns app --system --app | tail -n +1 | split row "\n" | append (ls $"/home/($user)/.local/share/flatpak/exports/bin/" | get name | each {|e| $e | path basename})
          $apps | filter {|x| not ($x in ($config | get flatpak-app-networking.allow-only))}
        } else { [] }

        let flatpaks_list = $flatpaks_list | append ($config | get flatpak-app-networking.block)

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
            let file_contents = "# IDWT_REPLACEABLE: Remove line if you want this file to not be automatically overwritten\n[Context]\nshared=!network;"
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
    print "## Applying: block-sites ##"

    let policy = {URLBlocklist: ($config | get block-sites)}
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
    
    let hosts = $config | get block-sites
    for host in $hosts {
        print $"INFO: Added '($host)' to hosts file"
        echo $"\n0.0.0.0 ($host)\n" | save --append $hosts_file
    }
}

def "main apply networking" [] {
    print "## Applying: networking ##"

    let affected_users = $config | get affected-users
    let schedules = $config | get networking.schedules

    for username in $affected_users {
        let mode = $config | get networking.mode
        if $mode == "allow" {
            print $"INFO: Allowing internet connection for user '($username)'"
            iptables -D OUTPUT -m owner --uid-owner $username -j REJECT
            ip6tables -D OUTPUT -m owner --uid-owner $username -j REJECT
        } else if $mode == "block" {
            print $"INFO: Blocking internet connection for user '($username)'"
            iptables -A OUTPUT -m owner --uid-owner $username -j REJECT
            ip6tables -A OUTPUT -m owner --uid-owner $username -j REJECT
        } else if $mode == "schedule" {
            let schedule_name = $config | get networking.schedule
            let schedule = $config | get networking.schedules | get $schedule_name

            let days_allowed = $schedule | get days_allowed | each { |day| $day | str downcase }
            let allow_start = $schedule | get allow_start
            let allow_end = $schedule | get allow_end

            let current_day = ^date +%A | str downcase
            let current_time = ^date +%H:%M
            if ($current_day in $days_allowed) and ($current_time >= $allow_start) and ($current_time < $allow_end) {
                print $"INFO: Allowing internet connection for user '($username)'"
                iptables -D OUTPUT -m owner --uid-owner $username -j REJECT
                ip6tables -D OUTPUT -m owner --uid-owner $username -j REJECT
            } else {
                print $"INFO: Blocking internet connection for user '($username)'"
                iptables -A OUTPUT -m owner --uid-owner $username -j REJECT
                ip6tables -A OUTPUT -m owner --uid-owner $username -j REJECT
            }
        }
    }
}

def "main apply" [] {
    try {main apply block-kwin-windows}
    try {main apply block-binaries}
    try {main apply block-sites}
    try {main apply flatpak-app-networking}
    try {main apply networking}
    try {main apply delayed_rules}
}
