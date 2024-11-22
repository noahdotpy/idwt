#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../lib/constants.nu *
use ../lib/group.nu *
use ../lib/regex.nu *
use ../lib/config.nu *

let config = get-config

def "main apply-user kill-gnome-windows" [] {
    print "## Applying: kill gnome windows ##"

    let window_ids = gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.List | cut -c 3- | rev | cut -c4- | rev | from json | get id
    
    for window_id in $window_ids {
        let window = try {
            gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.Details $window_id | cut -c 3- | rev | cut -c4- | rev | from json
        } catch {|err|
            $err.msg
        } 
        
        let window_class = $window | get wm_class_instance | default '' | describe
        let window_title = $window | get title | default '' | describe

        for rule in ($config | try { get kill-gnome-windows } | default []) {
            # if rule does not have one of [class, title] then continue
            if ($rule | columns | filter {|e| $e in ["class" "title"]} | length) <= 0 {
                continue
            }

            mut matched = []

            if (is_property_defined $rule class) and (does_regex_match $window_class $rule.class) {
                $matched = [...$matched "class"]
            }

            if (is_property_defined $rule title) and (does_regex_match $window_title $rule.title) {
                $matched = [...$matched "title"]
            }

            let should_kill_window = $matched == ($rule | columns)

            if $should_kill_window {
                try {
                    gdbus call --session --dest org.gnome.Shell --object-path /org/gnome/Shell/Extensions/Windows --method org.gnome.Shell.Extensions.Windows.Close $window_id
                } catch {|err|
                    print $err.msg
                }
                notify-send --app-name "IDWT" "Killed GNOME Window" $"Killed window with class: ($window_class), title: ($window_title)" --urgency=critical
            }
        }
    }
}

def "main apply-user" [] {
    try { main apply-user kill-gnome-windows } catch { |err| $err.msg }
}
