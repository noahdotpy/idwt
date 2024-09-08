#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *
use ../group.nu *
use ../lib.nu *
use ../config.nu *

# TODO: Add documentation for commands

def "main apply kwin-block-windows" [config: record] {
    echo "## Applying: kwin-block-windows ##"

    let group_prefix = "idwt-"

    let users_affected = $config | get kwin-block-windows | columns
    for user in $users_affected {
        let file = $"/home/($user)/.config/kwinrulesrc"
        
        if (not ($file | path exists)) {
            mkdir (dirname $file)
            echo "" | save $file
        }
            
        # TODO: find a way to cleanup all leftovers of an old IDWT configuration, instead of just the rules list
        let cleaned_rules = kreadconfig --file $file --group General --key rules | str replace -a -r 'idwt-.*' ''
        kwriteconfig --file $file --group General --key rules $cleaned_rules

        mut num = 0
        for rule in ($config | get kwin-block-windows | get $user) {
            let current_groups = rg $'\[($group_prefix)' $file | str replace "[" "" -a | str replace "]" "" -a | str replace "\n" " " -a | split row ' '

            let group_name = $"($group_prefix)($num)"

            kwriteconfig --file $file --group $group_name --key Description "Block Window - Automatically managed by IDWT"

            if (is_property_defined $rule class) {
                kwriteconfig --file $file --group $group_name --key wmclass ($rule | get class.value)
                if (is_property_defined ($rule | get class) whole_window_class) and ($rule | get class.whole_window_class) {
                    kwriteconfig --file $file --group $group_name --key wmclasscomplete "true"
                }
                kwriteconfig --file $file --group $group_name --key wmclassmatch (kwin_match_type_to_number ($rule | get class.match_type))
            }
            if (is_property_defined $rule title) {
                kwriteconfig --file $file --group $group_name --key title ($rule | get title.value)
                kwriteconfig --file $file --group $group_name --key titlematch (kwin_match_type_to_number ($rule | get title.match_type))
            }
            if (is_property_defined $rule role) {
                kwriteconfig --file $file --group $group_name --key windowrole ($rule | get role.value)
                kwriteconfig --file $file --group $group_name --key windowrolematch (kwin_match_type_to_number ($rule | get role.match_type))
            }

            # Always force minimize
            kwriteconfig --file $file --group $group_name --key minimize true
            kwriteconfig --file $file --group $group_name --key minimizerule 2

            # Always force size to be 1x1 pixels
            kwriteconfig --file $file --group $group_name --key size 1,1
            kwriteconfig --file $file --group $group_name --key sizerule 2

            # Do not obey geometry restrictions
            kwriteconfig --file $file --group $group_name --key strictgeometryrule 2

            let rules = kreadconfig --file $file --group General --key rules
            kwriteconfig --file $file --group General --key rules $"($rules),($group_name)"

            let count = kreadconfig --file $file --group General --key count | default 0
            let count = if ($count | is-empty) {0} else {$count | into int}
            kwriteconfig --file $file --group General --key count ($count + 1)
            $num += 1
        }
    }
}

def "main apply chromium-blocked-urls" [config: record] {
    echo "## Applying: chromium-blocked-urls ##"

    let policy = {URLBlocklist: ($config | get chromium.block-urls)}
    let policy_file = "/etc/chromium/policies/managed/idwt-auto-managed.json"

    mkdir ($policy_file | path dirname)
    $policy | to json | save -f $policy_file
}

def "main apply block-flatpak-networking" [config: record] {
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

def "main apply block-hosts" [config: record] {
    echo "## Applying: block-hosts ##"
    
    let hosts_file = "/etc/hosts.d/idwt-blocked.conf"

    if not ($hosts_file | path dirname | path exists) {
        mkdir ($hosts_file | path dirname)
    }

    if ($hosts_file | path exists) {
        rm $hosts_file
    }
    echo "## THIS FILE MAY BE REPLACED AT ANY TIME AUTOMATICALLY ##" | save --force $hosts_file
    echo $"INFO: Saving hosts file at '($hosts_file)'"

    if not (is_property_populated $config block-hosts) {
        echo "INFO: No hosts listed, skipping"
        return
    }
    
    let hosts = $config | get block-hosts
    for host in $hosts {
        echo $"INFO: Added '($host)' to hosts file"
        echo $"\n0.0.0.0 ($host)\n" | save --append $hosts_file
    }
}

def "main apply user-networking" [config: record] {
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
            let time_start = $schedule | get time_start
            let time_end = $schedule | get time_end

            let current_day = ^date +%A | str downcase
            let current_time = ^date +%H:%M
            if ($current_day in $days_allowed) and (current_time >= $time_start) and (current_time < $time_end) {
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
    let config = get_parsed_config

    main apply kwin-block-windows $config
    main apply block-hosts $config
    main apply block-flatpak-networking $config
    main apply chromium-blocked-urls $config
    main apply user-networking $config
}
