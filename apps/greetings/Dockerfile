FROM rust:1.56.0 as build-env

WORKDIR /app
COPY ./apps/greetings /app
RUN rustup component add rustfmt && \
    cargo build --release

FROM gcr.io/distroless/cc

COPY --from=build-env /app/target/release/greetings /
CMD ["./greetings"]
