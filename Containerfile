FROM rust
COPY . /context
RUN cargo install --bin idwt --path /context
RUN mkdir -p /out/bin/
RUN mv $CARGO_HOME/bin/idwt /out/bin/idwt

# Available tags should be (numbers changed to actual release):
# git      (for the latest git commit)
# {COMMIT_SHA}
# v{MAJOR} (eg: v1)
# v{MAJOR}.{MINOR}.{PATCH} (eg: v1.2.3)

# To use in  another container
# `COPY --from=ghcr.io/noahdotpy/idwt-rs:v1.2.3 /out/bin/idwt /usr/bin/idwt
