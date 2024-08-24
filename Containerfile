FROM alpine AS alpine-dev
RUN apk add nushell; \
    apk add sudo; \
    apk add shadow;

COPY src /
ENTRYPOINT [ "/usr/bin/nu", "--config", "/etc/nushell/config.nu", "--env-config", "/etc/nushell/env.nu"]

FROM fedora AS fedora-dev
RUN dnf install nu e2fsprogs iptables -y
RUN useradd john

COPY src /
ENTRYPOINT [ "/usr/bin/nu", "--config", "/etc/nushell/config.nu", "--env-config", "/etc/nushell/env.nu"]
FROM alpine AS clean-out
COPY src /out
RUN rm -r /out/etc

FROM scratch AS prod
COPY --from=clean-out /out /
COPY --from=clean-out /out /out/
