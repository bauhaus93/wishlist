#!/bin/sh

WWW_BUILD_DIR=./www
WWW_DIR='/var/frontend/'

mkdir -p $WWW_DIR && \
npm run build && \
cp -r -v $WWW_BUILD_DIR $WWW_DIR

