#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ./constants.nu *

export def "get_parsed_config" [] {
  let config = if (echo $usr_default_file | path exists) {
    yq eval '.' $usr_default_file
  } else {
    ''
  }
  let config = if (echo $etc_config_file | path exists) {
    echo $config | yq eval $". * load\("($etc_config_file)"\)"
  } else $config
  let config = if (echo $usr_override_file | path exists) {
    echo $config | yq eval $". *+ load\("($usr_override_file)"\)"
  } else $config
  return ($config | from yaml)
}
