FROM debian:buster-slim as build
LABEL stage=wishlist-build

RUN apt-get update && apt-get -y install curl gcc ca-certificates

WORKDIR /build
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal

ENV PATH "/root/.cargo/bin:$PATH"

COPY . .

RUN scripts/build.sh

FROM debian:buster-slim

WORKDIR /app
COPY --from=build /build/target/release/app .

CMD ["./app"]

