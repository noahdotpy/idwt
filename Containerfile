FROM alpine
COPY src /
COPY src /out
RUN apk add nushell