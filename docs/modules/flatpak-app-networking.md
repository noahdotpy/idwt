# Controlling a flatpak app's networking

This module works by creating a file in every user's (as defined in `users-affected`) `~/.local/share/flatpak/overrides` that contains a couple of lines that disable network access for every app defined.

## flatpak-app-networking.block

Every flatpak id in `flatpak-app-networking.block` is blocked with highest priority over any allow, always being blocked.

Below is an example of blocking GNOME Boxes virtualisation software.

```yml
flatpak-app-networking:
  block:
    - org.gnome.Boxes
```

## flatpak-app-networking.allow

This key is only useful if `flatpak-app-networking.block-otherwise` is set to `true`.

This key is to be used if you want to always allow flatpak apps. Input flatpak app ids in a list.

Below is an example of always allowing Obsidian markdown note-taker.

```yml
flatpak-app-networking:
  allow:
    - md.obsidian.Obsidian
```

## flatpak-app-networking.block-otherwise

If block-otherwise is set to true then only the flatpak app ids that are listed in `flatpak.app-networking.allow` will be allowed to access the network.

The default value for this key is `true`.

Below is an example of turning block-otherwise on.

```yml
flatpak-app-networking:
  block-otherwise: true
```
