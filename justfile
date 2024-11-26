export project_root := `git rev-parse --show-toplevel`

container-enter:
    #!/bin/sh
    just container-build
    podman run -it localhost/idwt-rs

container-build:
    podman build -t idwt-rs .

test:
    nu {{ project_root }}/tests/mod.nu
