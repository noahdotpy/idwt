FROM alpine AS alpine-dev
COPY src /out
RUN rm -r /out/etc/
COPY src /
RUN apk add nushell; \
    apk add sudo

FROM fedora AS dev
COPY src /out
RUN rm -r /out/etc/
COPY src /
RUN dnf install nu e2fsprogs iptables -y
RUN useradd john

FROM scratch AS prod
COPY --from=alpine-dev /out /out