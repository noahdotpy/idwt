export project_root := `git rev-parse --show-toplevel`

container-enter:
    #!/bin/sh
    just container-build
    podman run -it localhost/idwt

container-build:
    podman build -t idwt .
