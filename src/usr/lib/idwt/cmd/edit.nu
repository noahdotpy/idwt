#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *
use ../group.nu *

# TODO: Add documentation for commands

def "main edit group add" [
    user: string,
    group: string,
] {
    group_add $user $group
}

def "main edit group remove" [
    user: string,
    group: string,
] {
    group_remove $user $group
}

def "main edit config" [
    yq_eval_string: string # example: `.user-networking.users.john.mode = "block"`
] {
    let new_contents = yq eval $yq_eval_string $etc_config_file
    echo $new_contents | save -f $etc_config_file
}
