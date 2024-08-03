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

def "main edit config update" [
    field: cell-path,
    value: any
] {
    let config = open $config_file

    let new_config = $config | upsert $field $value

    $new_config | to yaml | save -f $config_file
    echo $new_config | to yaml
}

def "main edit config append" [
    field: cell-path
    value: any,
] {
    let config = open $config_file

    let new_value = $config | get -i $field | append $value
    let new_config = $config | upsert $field $new_value

    $new_config | to yaml | save -f $config_file
    echo $new_config | to yaml
}

def "main edit config" [
    --editor(-e): string, # editor to open config file in when `--open` is used
] {
    let editor = if $editor == null {
        "vim"
    } else {
        $editor
    }

    ^$editor $config_file
}