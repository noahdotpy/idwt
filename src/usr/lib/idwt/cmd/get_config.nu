#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../config.nu *

def "main get_parsed_config" [] {
  return (get_parsed_config --yaml)
}
