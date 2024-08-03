#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../../lib/idwt/constants.nu *
use ../../lib/idwt/lib.nu *

let temp_file = open $tighten_temp_file | from nuon
let command = $temp_file | get command

let tightener_config = open $config_file | get tightener-config
let approved_commands = $tightener_config | get approved-commands

if not (regex_matches_with_any $approved_edits $command) {
    echo $"ERROR: ($command) is not in approved tightener commands"
    rm $tighten_temp_file
    exit 1
}

sudo $idwt_bin edit $command

rm $tighten_temp_file