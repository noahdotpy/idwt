# Controlling a flatpak's networking access
<!-- TODO: Update these docs to the new name -->
This module works by creating a file in every user's (as defined in `users-affected`) `~/.local/share/flatpak/overrides` that contains a couple of lines that disable network access for every app defined.

## toggle-flatpak-networking.block

Every flatpak id in `toggle-flatpak-networking.block` is blocked with highest priority over any allow, always being blocked.

Below is an example of blocking GNOME Boxes virtualisation software.

```yml
toggle-flatpak-networking:
  block:
    - org.gnome.Boxes
```

## toggle-flatpak-networking.allow

This key is only useful if `toggle-flatpak-networking.block-otherwise` is set to `true`.

This key is to be used if you want to always allow flatpak apps. Input flatpak app IDs in a list.

Below is an example of always allowing Obsidian markdown note-taker.

```yml
toggle-flatpak-networking:
  allow:
    - md.obsidian.Obsidian
```

## toggle-flatpak-networking.block-otherwise

If block-otherwise is set to true then only the flatpak app IDs that are listed in `toggle-flatpak-networking.allow` will be allowed to access the network.

The default value for this key is `true`.

Below is an example of turning block-otherwise on.

```yml
flatpak-app-networking:
  block-otherwise: true
```
