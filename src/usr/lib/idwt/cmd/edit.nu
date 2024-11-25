#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../lib/constants.nu
use ../lib/group.nu *

# TODO: Add documentation for commands

def "main edit make_file_immutable" [
  path: string
] {
  /usr/bin/chattr +i $path
}

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

# TODO: figure out how I could possibly add a rule for kwin-block-windows

def "main edit config" [
    yq_eval_string: string # example: `.user-networking.users.john.mode = "block"`
] {
    let new_contents = yq eval $yq_eval_string $etc_config_file
    echo $new_contents | save -f $etc_config_file
}
