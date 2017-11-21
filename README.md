# Gopherbase, an overengineered Go development environment in Docker

[![Apache License v2.0](https://img.shields.io/badge/license-Apache%20License%202.0-blue.svg)](https://www.apache.org/licenses/LICENSE-2.0.txt)
[![Docker Layer Badge](https://images.microbadger.com/badges/image/wjkohnen/gopherbase.svg)](https://microbadger.com/images/wjkohnen/gopherbase)

WARNING: This image suffers from feature-creep. ;)

This is a quite large docker container that provides a development environment
for Go. Since I have used it for collaboration to the Go target of [ANTLR](https://github.com/antlr/antlr4)
it contains a lot of non-Go stuff like Java, Mono, NodeJS and such that is needed
to build ANTLR and whatever other project I was working on.

This image features from-source-built Vim, YouCompleteMe, Protobuffer and a bunch
of Go helper utilities like delve, gometalinter and dep.

This image is not meant to be used directly, but instead as a base image for an
image that configures an in-container user that matches UID and GID of the user
on the host system and that adds SSH keys et cetera. This is the derivate
Dockerfile that I use:

```
FROM    wjkohnen/gopherbase:latest
MAINTAINER Johannes Kohnen <wjkohnen@users.noreply.github.com>

# https://github.com/BurntSushi/ripgrep
COPY    rg /usr/local/bin/

RUN     addgroup --gid 1000 jb \
&&      adduser --disabled-password --gecos "Johannes Kohnen" --uid 1000 --ingroup jb jb \
&&      adduser jb staff
COPY    ssh/ /home/jb/.ssh/
RUN     chown -R jb: /home/jb

USER    jb
RUN     git config --global user.name "Johannes Kohnen" \
&&      git config --global user.email "wjkohnen@users.noreply.github.com"

ENV     GOPATH /go/default
WORKDIR /go
```

Given that image is called `gopher` I use a small wrapper script like this:

```
#!/bin/sh

exec docker run -ti --net=host -v $HOME/.config/direnv/allow-gopher:$HOME/.config/direnv/allow -v $HOME/.glide:$HOME/.glide -v $HOME/.m2:$HOME/.m2 -v $HOME/git:/git -v $HOME/go:/go "$@" gopher
```

## License
   Copyright 2017 Johannes Kohnen

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
