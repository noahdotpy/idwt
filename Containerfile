FROM alpine AS alpine-dev
RUN apk add nushell; \
    apk add sudo; \
    apk add yq; \
    apk add shadow;
COPY src /
COPY dev /
ENTRYPOINT [ "/usr/bin/nu", "--config", "/etc/nushell/config.nu", "--env-config", "/etc/nushell/env.nu"]

FROM fedora AS fedora-dev
RUN dnf install nu e2fsprogs iptables kde-runtime ripgrep yq -y
RUN useradd john
COPY src /
COPY dev /
ENTRYPOINT [ "/usr/bin/nu", "--config", "/etc/nushell/config.nu", "--env-config", "/etc/nushell/env.nu"]

FROM scratch AS prod
COPY src /
COPY src /out
