#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *
use ../group.nu *
use ../lib.nu *
use ../config.nu *
use ../apply/mod.nu *

let config = get_parsed_config

def "main apply process-killing" [] {
    apply process-killing
}

def "main apply delayed-rules" [] {
    apply delayed-rules
}

def "main apply block-kwin-windows" [] {
    apply block-kwin-windows
}

def "main apply flatpak-app-networking" [] {
    apply flatpak-app-networking
}

def "main apply block-sites" [] {
    apply block-sites
}

def "main apply block-networking" [] {
    apply block-networking
}

# TODO: Add a verbose log level that will print stuff like making flatpak overrides
def "main apply-all" [] {
    try {main apply block-kwin-windows}
    try {main apply process-killing}
    try {main apply block-sites}
    try {main apply flatpak-app-networking}
    try {main apply block-networking}
    try {main apply delayed-rules}
}

# TODO: Deprecate `apply` in favour of `apply-all`
def "main apply" [] {
    try { main apply block-kwin-windows     } catch { |err| $err.msg }
    try { main apply process-killing        } catch { |err| $err.msg }
    try { main apply block-sites            } catch { |err| $err.msg }
    try { main apply flatpak-app-networking } catch { |err| $err.msg }
    try { main apply block-networking       } catch { |err| $err.msg }
    try { main apply delayed-rules          } catch { |err| $err.msg }
}
