FROM fedora AS dev
COPY src /out
RUN rm -r /out/etc/
COPY src /
RUN dnf install nu e2fsprogs iptables -y
RUN useradd john

FROM scratch AS prod
COPY --from=dev /out /out