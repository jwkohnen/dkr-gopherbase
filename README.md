# Gopherbase, an overengineered Go development environment in Docker

[![Apache License v2.0](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.txt)
[![Docker Layer Badge](https://images.microbadger.com/badges/image/wjkohnen/gopherbase.svg)](https://microbadger.com/images/wjkohnen/gopherbase)

This is a quite large docker container that provides a development environment
for Go. Since I have used it for collaboration to the Go target of [ANTLR](https://github.com/antlr/antlr4)
it contains a lot of non-Go stuff like Java, Mono, NodeJS and such that is needed
to build ANTLR. 

This image features from-source-built Vim, YouCompleteMe, Protobuffer and a bunch
of Go helper utilities like delve, gometalinter and glide.

This image is not meant to be used directly, but instead as a base image for an
image that configures an in-container user that matches UID and GID of the user
on the host system and that adds SSH keys et cetera. This is the derivate
Dockerfile that I use:

```
FROM	wjkohnen/gopherbase:latest
MAINTAINER Wolfgang Johannes Kohnen <wjkohnen@users.noreply.github.com>

ARG	u=wjk
ARG	uid=1001
ARG	gid=1001
ARG	fn="Wolfgang Johannes Kohnen"
ARG	m="wjkohnen@users.noreply.github.com"

RUN	addgroup --gid $uid $u \
&&	adduser --disabled-password --gecos "$fn" --uid $uid --ingroup $u $u \
&&	adduser $u staff

COPY	ssh/ /home/$u/.ssh/
RUN	chown -R $u: /home/$u

USER	$u
RUN	git config --global user.name "$fn" \
&&	git config --global user.email "$m"

ENV	GOPATH /home/$u/go/default
WORKDIR	/go
```

Given that image is called `gopher` I use a small wrapper script like this:

```
#!/bin/sh

exec docker run --rm -ti -v $HOME/.m2:$HOME/.m2 -v $HOME/git:$HOME/git -v $HOME/go:$HOME/go "$@" gopher
```
