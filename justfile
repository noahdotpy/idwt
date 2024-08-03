build-run-dev:
    podman build -t idwt-dev --target dev .; podman run -it localhost/idwt-dev /usr/bin/nu -n
build-dev:
    podman build -t idwt-dev --target dev .

build-prod:
    podman build -t idwt-prod --target prod .