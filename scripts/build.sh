#!/bin/sh

FULL_REBUILD=0
CLEANUP=0
while getopts ":fc" option; do
	case "${option}" in
	c) CLEANUP=1 ;;
	esac
done

docker build -t wishlist-backend -f $PWD/docker/backend/Dockerfile $PWD/backend/ &&
	mkdir -p build &&
	cp -r $PWD/frontend $PWD/docker/frontend/mime.types $PWD/docker/frontend/nginx.conf $PWD/build &&
	docker build -t wishlist-frontend -f $PWD/docker/frontend/Dockerfile $PWD/build

if [ $CLEANUP -eq 1 ]; then
	docker image prune -f --filter label=stage=wishlist-build
	rm -rf build
fi
