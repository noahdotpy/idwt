#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../../lib/idwt/lib/config.nu *
use ../../lib/idwt/lib/constants.nu *
use ../../lib/idwt/lib/regex.nu *

let temp_file = open $tighten_temp_file | from nuon
let command = $temp_file | get command
let command_str = $command | str join ' '

let config = get-config
let tightener_config = $config | get tightener
let approved_commands = $tightener_config | get approved-commands

if not (regex_matches_with_any $command_str $approved_commands) {
    if not ($tightener_config | try { get delay-enabled } | default false) {
      print $"ERROR: ($command_str) is not in approved tightener commands and no delay is used"
      rm $tighten_temp_file
      exit 1
    }

    print $"INFO: ($command_str) is not in approved tightener commands - using delay feature at ($tightener_config | get delay) seconds instead"
    let current_time = ^date +%s | into int

    mut delay = $tightener_config | get delay

    for delay_rule in ($tightener_config | try { get delays } | default []) {
      let key = $delay_rule | columns | get 0
      if (does_regex_match $command ($key)) {
        $delay = $delay_rule | get $key
      }
    }

    let delayed_time = $current_time + $delay
    let pending = try {cat $pending_file | from yaml} | default []
    let new_file_contents = $pending | append {command: $command, time_to_apply: $delayed_time} | to yaml
    $new_file_contents | save -f $pending_file
} else {
  ^$idwt_bin edit ...$command
}

rm $tighten_temp_file
