#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *
use ../group.nu *
use ../lib.nu *

# TODO: Add documentation for commands

def "main apply block-flatpak-networking" [] {
    echo "## Applying: block-flatpak-networking ##"

    let config = open $config_file

    let users_affected = $config | get block-flatpak-networking.users-affected
    for user in $users_affected {
        let overrides_dir = $"/home/($user)/.local/share/flatpak/overrides"
        let flatpaks_list = $config | get block-flatpak-networking.apps
        for file in (ls $"($overrides_dir)") {
            let file_name = echo $file | get name | path basename
            let override_file = $"($overrides_dir)/($file_name)"
            if ((open $override_file) =~ "# IDWT_REPLACEABLE" and ($file_name in $flatpaks_list) == false) {
                chattr -i $override_file
                rm $override_file
                echo $"INFO: Removed redundant flatpak override at '($override_file)'"
            }
        }

        # if not (is_property_populated $config block-flatpak-networking) {
        #     echo "INFO: No flatpaks listed, skipping"
        #     return
        # }
    
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

def "main apply block-hosts" [--force] {
    echo "## Applying: block-hosts ##"
    
    let hosts_file = "/etc/hosts.d/idwt-blocked.conf"

    rm $hosts_file
    echo "## THIS FILE MAY BE REPLACED AT ANY TIME AUTOMATICALLY ##" | save --force $hosts_file
    echo $"INFO: Saving hosts file at '($hosts_file)'"

    let config = open $config_file

    # TODO: This does not properly detect that the property is populated, thus always skipping
    # TODO: Remove --force flag when this is fixed.
    if not (is_property_populated $config block-hosts) and not $force {
        echo "INFO: No hosts listed, skipping"
        return
    }
    
    let hosts = $config | get block-hosts
    for host in $hosts {
        echo $"INFO: Added '($host)' to hosts file"
        echo $"\n0.0.0.0 ($host)\n" | save --append $hosts_file
    }
}

def "main apply user-networking" [] {
    echo "## Applying: user-networking ##"

    let nowifi_users = open $config_file | get user-networking.users
    let schedules = open $config_file | get user-networking.schedules

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
    main apply block-hosts
    main apply block-flatpak-networking
    main apply user-networking
}
