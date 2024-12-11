# Splitting up configuration into multiple files

## Priority

| File location                      | Appends/overrides lists of previous file?       |
| ---------------------------------- | ----------------------------------------------- |
| /etc/idwt/config.yml               | Overrides default, even lists                   |
| /usr/share/idwt/config.yml         | Overrides previous file's keys, appending lists |

The configuration parser bases every step off the lower number priority file location.

## Locations changed from idwt (nu)

`/etc/idwt/config.d/*.yml` files are disabled.

There used to be a `/usr/share/idwt/default-config.yml` but this will be defined
in the code of idwt now.
