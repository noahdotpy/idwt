export project_root := `git rev-parse --show-toplevel`

alias be := build-enter
alias b := build
alias e := enter
alias t := test

build-enter TARGET="fedora-dev":
    #!/bin/sh
    just build {{ TARGET }}
    just enter {{ TARGET }}

build TARGET="fedora-dev":
    podman build -t idwt-{{ TARGET }} --target {{ TARGET }} .

enter TARGET="fedora-dev":
    podman run -it localhost/idwt-{{ TARGET }}

test:
    nu {{ project_root }}/tests/mod.nu
