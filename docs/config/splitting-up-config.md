# Splitting up configuration into multiple files

## Priority

| #   | File location                      | Appends/overrides lists of previous file?       | Extra Notes                                                                                                  |
| --- | ---------------------------------- | ----------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| 1   | /usr/share/idwt/default-config.yml |                                                 |                                                                                                              |
| 2   | /etc/idwt/config.yml               | Overrides default, even lists                   |                                                                                                              |
| 3   | /etc/idwt/config.d/\*.yml          | Overrides previous file's keys, appending lists | Files are applied in alphabetical order, higher character (z is higher compared to a) having higher priority |
| 4   | /usr/share/idwt/config.yml         | Overrides previous file's keys, appending lists |                                                                                                              |

The configuration parser bases every step off the lower number priority file location.
