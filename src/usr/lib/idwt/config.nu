#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ./constants.nu *

# *    = merge, no append
# *+   = merge, and append

export def "get_parsed_config" [--yaml] {
  mut config = ''

  $config = if ($default_config_file | path exists) {
    yq eval '.' $default_config_file
  } else $config

  $config = if ($etc_config_file | path exists) {
    $config | yq eval $". * load\("($etc_config_file)"\)"
  } else $config

  for file in (ls $etc_config_dir | where type == file | where name ends-with ".yml") {
    $config | yq eval $". *+ load\("($file.name)"\)"
  }

  let config = if ($persistent_config_file | path exists) {
    $config | yq eval $". *+ load\("($persistent_config_file)"\)"
  } else $config

  if $yaml {
    return $config
  } else {
    return ($config | from yaml)
  }

}
