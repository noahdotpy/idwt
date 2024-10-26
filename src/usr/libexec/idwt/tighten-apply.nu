#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../../lib/idwt/config.nu *
use ../../lib/idwt/constants.nu *
use ../../lib/idwt/lib.nu *

let temp_file = open $tighten_temp_file | from nuon
let command = $temp_file | get command
let command_str = $command | str join ' '

let config = get_parsed_config
let tightener_config = $config | get tightener
let approved_commands = $tightener_config | get approved-commands

if not (regex_matches_with_any $approved_commands $command_str) {
    if not ($tightener_config | try {get delay-enabled} | default false) {
      print $"ERROR: ($command_str) is not in approved tightener commands and no delay is used"
      rm $tighten_temp_file
      exit 1
    }

    print $"INFO: ($command_str) is not in approved tightener commands - using delay feature at ($tightener_config | get delay) seconds instead"
    let current_time = ^date +%s | into int
    let delayed_time = $current_time + ($tightener_config | get delay)
    let delayed_rules = try {cat $delayed_rules_file | from yaml} | default []
    let new_file_contents = $delayed_rules | append {command: $command, time_to_apply: $delayed_time} | to yaml
    $new_file_contents | save -f $delayed_rules_file
} else {
  ^$idwt_bin edit ...$command
}

rm $tighten_temp_file
