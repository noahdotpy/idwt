#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ./constants.nu *

export def "get_parsed_config" [] {
  let config = if (echo $default_config_file | path exists) {
    yq eval '.' $default_config_file
  } else ''

  let config = if (echo $etc_config_file | path exists) {
    echo $config | yq eval $". * load\("($etc_config_file)"\)"
  } else $config

  let config = if (echo $persistent_config_file | path exists) {
    echo $config | yq eval $". *+ load\("($persistent_config_file)"\)"
  } else $config

  return ($config | from yaml)
}
