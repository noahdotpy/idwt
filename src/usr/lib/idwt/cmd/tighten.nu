#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../lib/constants.nu *


# Tighten executes `idwt edit {command}` under the hood.
# Tighten should always be used instead of edit, unless the current user has super-user privileges.
# A delay-system like Plucky filter is used in tighten for commands which are not allowed to be tightened immediately if delay feature is enabled.
# `/usr/libexec/idwt/tighten-apply.nu` should be allowed for any user in idwt-tightener group.
#   - This can be done with a sudoers file (example file location: /etc/sudoers.d/allow-idwtn).
#   - An example for the contents of this file is below:
#       `%idwt-tightener ALL=(ALL) NOPASSWD: /usr/libexec/idwt/tighten-apply.nu`
# Examples:
#   idwt tighten config '.block-hosts += "youtube.com"'
#   idwt tighten config '.user-networking.john.mode = "allow"'
#   idwt tighten group remove noah wheel

# Edit approved configuration without admin.
def "main tighten" [
    ...command: string # The subcommand to pass to `idwt edit`
] {
    {command: $command} | to nuon | save -f $tighten_temp_file
    ^sudo $tighten_apply_bin
}
