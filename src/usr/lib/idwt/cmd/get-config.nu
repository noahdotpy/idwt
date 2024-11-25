#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../lib/config.nu *

def "main get-config" [] {
  return (get-config --yaml)
}
