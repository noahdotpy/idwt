#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ./constants.nu *
use ./schedule.nu *

# *    = merge, no append
# *+   = merge, and append

def "merge_configs" [] -> string {
  mut config = ''

  $config = if ($default_config_file | path exists) {
    yq eval '.' $default_config_file
  } else $config

  $config = if ($etc_config_file | path exists) {
    $config | yq eval $". * load\("($etc_config_file)"\)"
  } else $config

  if ($etc_config_dir | path exists) {
    for file in (ls $etc_config_dir | where type == file | where name ends-with ".yml") {
      $config = $config | yq eval $". *+ load\("($file.name)"\)"
    }
  }

  let config = if ($persistent_config_file | path exists) {
    $config | yq eval $". *+ load\("($persistent_config_file)"\)"
  } else $config
  
  return $config
}

# TODO: Fix this, it's probably not working
def "apply_whens" [config: string] -> string {
  for when_rule in ($config | from yaml | try { get when } | default []) {
    let day_time = {
      day: (^date +%A | str downcase),
      time: (^date +%H:%M:%S)
    }
    let should_apply = is_day_time_in_schedule ($when_rule | get schedule) $day_time

    if not $should_apply {
      continue
    }
    
    let mode = $when_rule | try { get technique } | default "append"
    let temp_file = "/tmp/idwt-apply-whens"

    $when_rule | get rule | to yaml | save -f $temp_file

    let new_config = if ($mode == "append") {
      $config | yq eval $". *+ load\("($temp_file)"\)"
    } else if ($mode == "replace") {
      $config | yq eval $". * load\("($temp_file)"\)"
    }

    return $new_config
  }

  return $config
}

export def "get-config" [--yaml] {
  let config = merge_configs
  let config = try { apply_whens $config } catch { $config }

  if $yaml {
    return $config
  } else {
    return ($config | from yaml)
  }
}
