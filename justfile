build-run:
    podman build -t idwt .; podman run -it localhost/idwt /usr/bin/nu -n
build:
    podman build -t idwt .