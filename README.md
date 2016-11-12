This is a quite large docker container that provides a developement environment
for Go. Since I have used it for collaboration to the Go target of [ANTLR](https://github.com/antlr/antlr4)
it contains a lot of non-Go stuff like Java, Mono, NodeJS and such that is needed
to build ANTLR. Thats also why it is based on Ubuntu Trusty (instead of Debian,
which I'd prefer); you will find some similarities to ANTLR's travis-ci setup.

This image features from-source-built Vim, YouCompleteMe, Protobuffer and a bunch
of Go helper utilities like delve, gometalinter and glide.

This image is not meant to be used directly, but instead as a base image for an
image that configures a in-container user that matches UID and GID of the user
on the host system and that adds SSH keys et cetera. This is the derivate
Dockerfile that I use:

```
FROM	wjkohnen/gopherbase:2016-11-12
MAINTAINER Wolfgang Johannes Kohnen <wjkohnen@users.noreply.github.com>

ARG	u=wjk
ARG	uid=1001
ARG	gid=1001
ARG	fn="Wolfgang Johannes Kohnen"
ARG	m="wjkohnen@users.noreply.github.com"

RUN	addgroup --gid 1001 $u \
&&	adduser --disabled-password --gecos "$fn" --uid $uid --ingroup $u $u \
&&	adduser $u staff

COPY	ssh/ /home/$u/.ssh/
RUN	chown -R $u: /home/$u

USER	$u
RUN	git config --global user.name "$fn" \
&&	git config --global user.email "$m" \
&&	git config --global alias.st status \
&&	git config --global push.default simple \
&&	git config --global commit.verbose true

ENV	GOPATH /go/default
#ENV	PATH $PATH:/home/$u/go/bin
WORKDIR	/go
VOLUME	/go
VOLUME	/git
```
