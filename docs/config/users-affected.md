# Setting Users Affected (needed for some modules)

## users-affected

This key is a required key for some modules (example: flatpak-app-networking). This is because those modules require to go through multiple user's directories and change them all in some way or read from them to gain critical information for the module to operate correctly.

To use this key you just enter a list of usernames.

Below is an example of adding John to the users affected.

```yml
users-affected: [john]
```
