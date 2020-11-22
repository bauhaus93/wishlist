#!/bin/sh

RUST_LOG="app=debug,wishlist=debug" cargo build --release --bin app
