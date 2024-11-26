# I Don't Want To (IDWT)

## Usage

### How to use in containers

Outputs available:

- /out/bin/idwt

Tags available:

- git (for the latest git commit)
- {COMMIT_SHA} (eg: 74224c0)
- {MAJOR} (eg: 1)
- {MAJOR}.{MINOR}.{PATCH} (eg: 1.2.3)

Below is an example of copying /out/bin/idwt to /usr/bin/idwt with idwt-rs version 1.2.3

```containerfile
COPY --from=ghcr.io/noahdotpy/idwt-rs:1.2.3 /out/bin/idwt /usr/bin/idwt
```

## Dependencies

All modules:

- jc

kill-gnome-windows:

- [ickyicky/window-calls](https://github.com/ickyicky/window-calls) (make sure to force usage of this extension so the user doesn't disable it)
