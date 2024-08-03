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
    path: cell-path,
    value: any,
    --show-new # Show the newly changed config file
] {
    let config = open $config_file

    let new_config = $config | upsert $path $value

    $new_config | to yaml | save -f $config_file
    if $show_new {
        echo $new_config | to yaml
    }
}

def "main edit config append" [
    path: cell-path,
    value: any,
    --show-new # Show the newly changed config file
] {
    let config = open $config_file

    let new_value = $config | get -i $path | append $value
    let new_config = $config | upsert $path $new_value

    $new_config | to yaml | save -f $config_file
    if $show_new {
        echo $new_config | to yaml
    }
}

def "main edit config" [
    --editor(-e): string, # Editor to open config file in when `--open` is used
] {
    let editor = if $editor == null {
        "vim"
    } else {
        $editor
    }

    ^$editor $config_file
}