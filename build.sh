#!/bin/bash
set -xeuo pipefail

VERSION=$(git describe --tags --always --dirty="-dev")
BUILD_DATE=$(date -u '+%Y-%m-%d-%H%M UTC')
VCS_REF=$(git rev-parse HEAD)
docker build . -f Dockerfile -t wjkohnen/gopherbase:${TAG} \
	--build-arg VERSION="${VERSION}" \
	--build-arg BUILD_DATE="${BUILD_DATE}" \
	--build-arg VCS_REF="${VCS_REF}" \
	$@
docker tag wjkohnen/gopherbase:${TAG} wjkohnen/gopherbase:latest
