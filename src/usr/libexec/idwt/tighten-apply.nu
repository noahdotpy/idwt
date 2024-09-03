#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../../lib/idwt/config.nu *
use ../../lib/idwt/constants.nu *
use ../../lib/idwt/lib.nu *

let temp_file = open $tighten_temp_file | from nuon
let command = $temp_file | get command
let command_str = $command | str join ' '

let config = get_parsed_config
let tightener_config = $config | get tightener-config
let approved_commands = $tightener_config | get approved-commands

if not (regex_matches_with_any $approved_commands $command_str) {
    echo $"ERROR: ($command_str) is not in approved tightener commands"
    rm $tighten_temp_file
    exit 1
}

^$idwt_bin edit ...$command

rm $tighten_temp_file
