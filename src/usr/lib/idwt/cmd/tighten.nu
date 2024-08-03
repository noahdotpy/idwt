#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../constants.nu *


# Tighten executes `idwt edit {command}` under the hood.
# `/usr/libexec/idwt/tighten-apply.nu` should be allowed for any user in idwt-tightener group.
#   - This can be done with a sudoers file (example file location: /etc/sudoers.d/allow-idwtn).
#   - An example for the contents of this file is below:
#       `%idwt-tightener ALL=(ALL) NOPASSWD: /usr/libexec/idwt/tighten-apply.nu`
# Examples:
#   idwt tighten config append block-hosts facebook.com
#   idwt tighten config update user-networking.users.noah.mode block
#   idwt tighten group remove noah wheel

# Edit approved configuration without admin for a group of users.
def "main tighten" [
    ...command: string # The subcommand to pass to edit (example: `config append block-hosts youtube.com` uses this under the hood `idwt edit config append block-hosts youtube.com`)
] {
    {command: ($command | str join ' ')} | to nuon | save -f $tighten_temp_file
    ^sudo /usr/libexec/idwt/tighten-apply.nu
}