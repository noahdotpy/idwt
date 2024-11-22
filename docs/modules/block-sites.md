# Blocking Websites

## block-sites

This key is a list of websites (including specific pages within a website).

Below is an example of blocking websites.

If you want to block a whole host, use the host name (example: `youtube.com`) rather than a URL (example: `https://youtube.com`).

To block subdomains you have to enter each one individually. As an example, if you add `example.com` to `block-sites` it will still not block `subdomain.example.com`.

If you want to block specific pages within a website do something like the following: `- github.com/noahdotpy/idwt`. This currently only works on chromium (does not work on chromium-based, just chromium).

This module works by adding a `0.0.0.0 {website}` line in `/etc/hosts.d/idwt-blocked.conf`

- Note that this file path is likely only useful if you are on my image based on Fedora Silverblue which includes a systemd service to make a `/etc/hosts` file based on the contents of `/etc/hosts.d`.

```yml
block-sites:
  - github.com/noahdotpy/idwt
  - youtube.com
```
