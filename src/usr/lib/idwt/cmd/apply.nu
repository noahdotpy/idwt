#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *
use ../group.nu *
use ../lib.nu *
use ../config.nu *

# TODO: Add documentation for commands

let config = get_parsed_config

# TODO: Add name and id keys for kwin-block-windows to allow describing it in the system settings

def "main apply kwin-block-windows" [] {
    echo "## Applying: kwin-block-windows ##"

    let group_prefix = "idwt-"

    let file = "/etc/xdg/kwinrulesrc"

    mut lines = ["# IDWT MANAGED: FILE WILL BE CHANGED"]
    mut rules = []

    mut num = 0
    for rule in ($config | get kwin-block-windows) {
      $num += 1

      $rules = [...$rules $"($group_prefix)($num)"]

      $lines = [...$lines $"[($group_prefix)($num)][$i]"]
      $lines = [...$lines $"Description=IDWT_FORCED ($num): Window disabled"]

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
    }

    $lines = [...$lines $"[General][$i]"]
    $lines = [...$lines $"count=($num)"]
    $lines = [...$lines $"rules=($rules | str join ',')"]

    $lines | str join "\n" | save -f $file 
}

def "main apply block-flatpak-networking" [] {
    echo "## Applying: block-flatpak-networking ##"

    let users_affected = $config | get block-flatpak-networking | columns
    
    for user in $users_affected {
        let overrides_dir = $"/home/($user)/.local/share/flatpak/overrides"
        let flatpaks_list = $config | get block-flatpak-networking | get $user
        mkdir $overrides_dir
        for file in (ls $"($overrides_dir)") {
            let file_name = echo $file | get name | path basename
            let override_file = $"($overrides_dir)/($file_name)"
            if ((open $override_file) =~ "# IDWT_REPLACEABLE" and ($file_name in $flatpaks_list) == false) {
                chattr -i $override_file
                rm $override_file
                echo $"INFO: Removed redundant flatpak override at '($override_file)'"
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
                echo $"INFO: Created flatpak override at '($override_file)'"
            } else {
                echo $"INFO: Skipping overwriting ($override_file)"
            }
        }
    }
}

def "main apply block-sites" [] {
    echo "## Applying: block-sites ##"

    let policy = {URLBlocklist: ($config | get block-sites)}
    let policy_file = "/etc/chromium/policies/managed/idwt-auto-managed.json"

    mkdir ($policy_file | path dirname)
    $policy | to json | save -f $policy_file
    
    let hosts_file = "/etc/hosts.d/idwt-blocked.conf"

    if not ($hosts_file | path dirname | path exists) {
        mkdir ($hosts_file | path dirname)
    }

    if ($hosts_file | path exists) {
        rm $hosts_file
    }
    echo "## THIS FILE MAY BE REPLACED AT ANY TIME AUTOMATICALLY ##" | save --force $hosts_file
    echo $"INFO: Saving hosts file at '($hosts_file)'"

    if not (is_property_populated $config block-sites) {
        echo "INFO: No hosts listed, skipping"
        return
    }
    
    let hosts = $config | get block-sites
    for host in $hosts {
        echo $"INFO: Added '($host)' to hosts file"
        echo $"\n0.0.0.0 ($host)\n" | save --append $hosts_file
    }
}

def "main apply user-networking" [] {
    echo "## Applying: user-networking ##"

    let nowifi_users = $config | get user-networking.users
    let schedules = $config | get user-networking.schedules

    for username in ($nowifi_users | columns) {
        let user = $nowifi_users | get $username
        let mode = $user | get mode
        if $mode == "allow" {
            echo $"INFO: Allowing internet connection for user '($username)'"
            iptables -D OUTPUT -m owner --uid-owner $username -j REJECT
            ip6tables -D OUTPUT -m owner --uid-owner $username -j REJECT
            notify-send --app-name "IDWT" "Reboot May Be Required" "You may have to reboot to use internet again"
        } else if $mode == "block" {
            echo $"INFO: Blocking internet connection for user '($username)'"
            iptables -A OUTPUT -m owner --uid-owner $username -j REJECT
            ip6tables -A OUTPUT -m owner --uid-owner $username -j REJECT
        } else if $mode == "schedule" {
            let schedule_name = $user | get schedule
            let schedule = $schedules | get $schedule_name

            let days_allowed = $schedule | get days_allowed | each { |day| $day | str downcase }
            let allow_start = $schedule | get allow_start
            let allow_end = $schedule | get allow_end

            let current_day = ^date +%A | str downcase
            let current_time = ^date +%H:%M
            if ($current_day in $days_allowed) and ($current_time >= $allow_start) and ($current_time < $allow_end) {
                echo $"INFO: Blocking internet connection for user '($username)'"
                iptables -A OUTPUT -m owner --uid-owner $username -j REJECT
                ip6tables -A OUTPUT -m owner --uid-owner $username -j REJECT
            } else {
                echo $"INFO: Allowing internet connection for user '($username)'"
                iptables -D OUTPUT -m owner --uid-owner $username -j REJECT
                ip6tables -D OUTPUT -m owner --uid-owner $username -j REJECT
                notify-send --app-name "IDWT" "Reboot May Be Required" "You may have to reboot to use internet again"
            }
        }
    }
}

def "main apply" [] {
    try {main apply kwin-block-windows}
    try {main apply block-sites}
    try {main apply block-flatpak-networking}
    try {main apply user-networking}
}
