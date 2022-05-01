# Build Stage
FROM ubuntu:20.04 as builder

## Install build dependencies.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y cmake clang curl
RUN curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN ${HOME}/.cargo/bin/rustup default nightly
RUN ${HOME}/.cargo/bin/cargo install -f cargo-fuzz

## Add source code to the build stage.
ADD . /rustls
WORKDIR /rustls

RUN cd fuzz && ${HOME}/.cargo/bin/cargo fuzz build

# Package Stage
FROM ubuntu:20.04

COPY --from=builder rustls/fuzz/target/x86_64-unknown-linux-gnu/release/client /
COPY --from=builder rustls/fuzz/target/x86_64-unknown-linux-gnu/release/deframer /
COPY --from=builder rustls/fuzz/target/x86_64-unknown-linux-gnu/release/fragment /
COPY --from=builder rustls/fuzz/target/x86_64-unknown-linux-gnu/release/hsjoiner /
COPY --from=builder rustls/fuzz/target/x86_64-unknown-linux-gnu/release/message /
COPY --from=builder rustls/fuzz/target/x86_64-unknown-linux-gnu/release/persist /
COPY --from=builder rustls/fuzz/target/x86_64-unknown-linux-gnu/release/server /


