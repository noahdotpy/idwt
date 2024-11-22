# Blocking a user's access to internet

## block-networking

This module uses iptables to add a REJECT rule to all users listed in the `affected-users` key.

The default value for this key is `false`.

Below is an example of blocking internet.

```yml
block-networking: true
```
