alias be := build-enter
alias b := build
alias e := enter

build-enter TARGET="fedora-dev":
    #!/bin/sh
    just build {{ TARGET }}
    just enter {{ TARGET }}

build TARGET="fedora-dev":
    podman build -t idwt-{{ TARGET }} --target {{ TARGET }} .

enter TARGET="fedora-dev":
    podman run -it localhost/idwt-{{ TARGET }}