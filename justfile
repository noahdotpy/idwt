alias be := build-enter
alias b := build
alias e := enter

build-enter TARGET="alpine-dev":
    #!/bin/sh
    just build {{TARGET}}
    just enter {{TARGET}}

build TARGET="alpine-dev":
    podman build -t idwt-{{ TARGET }} --target {{ TARGET }} .

enter TARGET="alpine-dev":
    podman run -it localhost/idwt-{{ TARGET }}