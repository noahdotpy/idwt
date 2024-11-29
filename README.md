# I Don't Want To (IDWT)

## Runtime Dependencies

- A system with `iptables` enabled
- `/usr/bin/yq` for the `tighten` command
- `/usr/bin/sudo` for the `edit` command
- `/usr/bin/gpasswd` for the `revoke-admin` module

## Usage

### How to use in containers

Below is a table describing where the outputs from the `idwt-rs` container should go.

| Output path                      | Recommended Destination          |
|----------------------------------|----------------------------------|
| /out/bin/idwt                    | /usr/bin/idwt                    |

Tags available:

- `git` (for the latest git commit)
- `{COMMIT_SHA}` (eg: 74224c0)
- `{MAJOR}` (eg: 1)
- `{MAJOR}.{MINOR}.{PATCH}` (eg: 1.2.3)

Below is an example of copying /out/bin/idwt to /usr/bin/idwt with idwt-rs version 1.2.3

```containerfile
COPY --from=ghcr.io/noahdotpy/idwt-rs:1.2.3 /out/bin/idwt /usr/bin/idwt
```
