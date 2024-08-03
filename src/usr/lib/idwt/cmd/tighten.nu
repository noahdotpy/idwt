#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *

# Allow specific approved configuration by users with idwt-tightener group
# This subcommand uses `idwt edit` under the hood via /usr/libexec/idwt/tighten-apply.nu, which should then be allowed to be executed by a group of users.
# Examples:
#   idwt tighten config append block-hosts facebook.com
#   idwt tighten config update user-networking.users.noah.mode block
#   idwt tighten group remove noah wheel
def "main tighten" [
    action: string,    # The edit action to take (example: `config update` uses `idwt edit config update ...` under the hood)
    path: string,     # The field to take action on (example: block-hosts)
    value: any,        # The value to update/append to the field (example: youtube.com)
] {
    {command: $"($action) ($path) ($value)"} | to nuon | save -f $tighten_temp_file

    ^$"sudo" /usr/libexec/idwt/tighten-apply.nu
}