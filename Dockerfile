# Copyright 2018 Johannes Kohnen

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM	debian:testing
MAINTAINER	Johannes Kohnen <wjkohnen@users.noreply.github.com>

CMD	["/bin/bash", "-li"]

RUN	dpkg-divert /etc/locale.gen
COPY	locale.gen /etc/
# COPY	sources.list /etc/apt/
COPY	fixperms /usr/local/sbin/

# http://stackoverflow.com/a/26217767/2715936 !?!?
ENV	DEBIAN_FRONTEND noninteractive
RUN	apt-get update \
&&	apt-get -yqq install dpkg apt \
&&	apt-get -yqq upgrade \
&& 	apt-get -fyqq dist-upgrade \
&&	apt-get -yqq --no-install-recommends install locales apt-utils gnupg2 dirmngr \
&&	echo tzdata tzdata/Zones/Etc select UTC | debconf-set-selections \
&&	echo debconf debconf/priority select critical | debconf-set-selections \
&&	echo debconf debconf/frontend select readline | debconf-set-selections \
&&	echo debconf debconf/frontend seen false | debconf-set-selections \
&&	locale-gen \
&&	dpkg-reconfigure locales \
&&	dpkg-reconfigure tzdata \
&&	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
&&	echo "deb http://download.mono-project.com/repo/debian wheezy main" > /etc/apt/sources.list.d/mono-xamarin.list \
&&	apt-get update \
&&	apt-get install -yqq --no-install-recommends \
		vim-tiny- \
		nvi \
		build-essential \
		git \
		sudo \
		screen \
		mercurial \
		subversion \
		cvs \
		bzr \
		ncurses-dev \
		python-dev \
		cmake \
		curl \
		bash-completion \
		pv \
		zip \
		autoconf \
		automake \
		libtool \
		libcap-dev \
		software-properties-common \
		apt-transport-https \
		graphviz  \
		faketime \
		tree \
		nodejs \
		maven \
		python3 \
		nodejs \
		mono-complete \
		unzip \
		default-jdk-headless \
		openssh-client \
		less \
		upx-ucl \
		libwebp-dev \
		libvips-tools \
		fftw-dev \
		musl-dev \
		libvips-dev \
		direnv \
&&	apt-get autoremove \
&&	apt-get clean \
&&	rm -rf /var/lib/apt/lists/* \
ENV	LANG=en_US.UTF-8

ARG	DKR_ANTLR_VERSION=4.7.1
RUN	git clone --depth=1 --branch $DKR_ANTLR_VERSION https://github.com/antlr/antlr4.git /tmp/antlr \
&&	( cd /tmp/antlr/tool && mvn package -DskipTests ) \
&&	cp /tmp/antlr/tool/target/antlr4-${DKR_ANTLR_VERSION}-complete.jar /usr/local/lib/ \
&&	rm -rf /tmp/antlr /root/.m2
ENV	CLASSPATH .:/usr/local/lib/antlr4-${DKR_ANTLR_VERSION}-complete.jar

ARG	_DKR_PROTOBUF_VERSION=v3.6.0
RUN	git clone --depth=1 https://github.com/google/protobuf --branch $_DKR_PROTOBUF_VERSION /tmp/protobuf \
&&	cd /tmp/protobuf \
&&	git submodule update --init --recursive \
&&	./autogen.sh \
&&	./configure \
&&	make \
&&	make check \
&&	make install \
&&	ldconfig \
&&	rm -rf /tmp/protobuf \
&&	fixperms

RUN	git clone --depth=1 https://github.com/vim/vim.git /tmp/vim \
&&	cd /tmp/vim \
&&	./configure \
		--enable-pythoninterp \
		--with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
&&	cd /tmp/vim && make \
&&	make install \
&&	rm -rf /tmp/vim \
&&	update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 100 \
&&	update-alternatives --set vi /usr/local/bin/vim
ENV	EDITOR vim

ARG	_DKR_VIMGO_VERSION=v1.17
RUN	mkdir -p /etc/skel/.vim/autoload \
&&	mkdir -p /etc/skel/.vim/bundle \
&&	curl -LSso /etc/skel/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim \
&&	git clone --depth=1 https://github.com/fatih/vim-go.git --branch $_DKR_VIMGO_VERSION /etc/skel/.vim/bundle/vim-go \
&&	git clone --depth=1 --shallow-submodules https://github.com/Valloric/YouCompleteMe.git /opt/YouCompleteMe  \
&&	cd /opt/YouCompleteMe \
&&	git submodule update --init --jobs=4 --recursive \
&&	./install.py \
&&	fixperms \
&&	ln -s /opt/YouCompleteMe /etc/skel/.vim/bundle/YouCompleteMe
ADD	vimrc /etc/skel/.vimrc

# download go source and build 1.4 for bootstrapping
RUN	git clone https://go.googlesource.com/go /usr/local/go-tip \
&&	git clone --shared --branch go1.4.3 /usr/local/go-tip /usr/local/go1.4 \
&&	cd /usr/local/go1.4/src \
&&	CGO_ENABLED=0 ./make.bash \
&&	fixperms

# build current release into /usr/local/go using 1.4 for bootstrap
ARG	_DKR_GO_RELEASE=1.10
RUN	git clone --branch release-branch.go${_DKR_GO_RELEASE} --reference /usr/local/go-tip https://go.googlesource.com/go /usr/local/go \
&&	cd /usr/local/go/src \
&&	GOROOT_BOOTSTRAP=/usr/local/go1.4 ./make.bash \
&&	fixperms

# build tip into go-tip, using current release as bootstrap
ARG	_BUMP=2018-03-28
RUN	cd /usr/local/go-tip/src \
&&	git checkout master \
&&	git pull \
&&	GOROOT_BOOTSTRAP=/usr/local/go ./make.bash \
&&	fixperms

# keep PATH in sync with bashrc!
ENV	PATH /usr/local/go-tip/bin:$PATH

# cache some go runtimes
RUN	GOOS=windows go install -v std \
&&	GOOS=darwin go install -v std \
&&	GOARCH=386 go install -v std \
&&	GOARCH=arm GOARM=6 go install -v std \
&&	GOARCH=arm GOARM=7 go install -v std \
&&	GOARCH=arm GOARM=6 go install -v -race std \
&&	GOARCH=arm GOARM=7 go install -v -race std \
&&	GOARCH=amd64 go install -v -race std \
&&	fixperms

RUN	GOPATH=/tmp/gotools \
	GOBIN=/usr/local/bin \
	/bin/sh -c "\
		go get -v \
			golang.org/x/tools/cmd/... \
			github.com/mdempsky/gocode \
			github.com/rogpeppe/godef \
			github.com/golang/lint/golint \
			github.com/jstemmer/gotags \
			github.com/garyburd/go-explorer/src/getool \
			github.com/alecthomas/gometalinter \
			github.com/klauspost/asmfmt/cmd/asmfmt \
			github.com/josharian/impl \
			github.com/fatih/motion \
			github.com/zmb3/gogetdoc \
			github.com/derekparker/delve/cmd/dlv \
			github.com/Masterminds/glide \
			github.com/golang/protobuf/proto \
			github.com/golang/protobuf/protoc-gen-go \
			github.com/golang/dep/... \
			github.com/spf13/cobra/cobra \
			github.com/kardianos/govendor \
			github.com/fatih/gomodifytags \
			github.com/golang/mock/gomock \
			github.com/golang/mock/mockgen \
			github.com/vektra/mockery/... \
			github.com/tockins/realize \
			golang.org/x/review/git-codereview \
			github.com/mailru/easyjson/... \
			github.com/pquerna/ffjson \
			github.com/spf13/cobra/cobra \
			github.com/boyter/lc \
			golang.org/x/vgo \
			github.com/gogo/protobuf/... \
			github.com/go-critic/go-critic/... \
		&& ( cd /tmp/gotools/src/github.com/golang/protobuf && make ) \
		&& /usr/local/bin/gometalinter --install \
		&& cp -a /etc/skel/.vim* /root/ \
		&& vim +GoInstallBinaries +q \
		&& rm -r /root/.vim* \
	" \
&&	rm -r /tmp/gotools \
&&	fixperms

RUN	dpkg-divert /etc/ssh/ssh_config \
&&	echo "%staff ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/sudo_nopasswd \
&&	mkdir /etc/skel/.ssh \
&&	chmod 700 /etc/skel/.ssh \
&&	echo '. ~/.bashrc_gopher' >> /etc/skel/.bashrc \
&&	git clone --depth=1 https://github.com/magicmonty/bash-git-prompt.git /etc/skel/.bash-git-prompt
COPY	bashrc /etc/skel/.bashrc_gopher
COPY	ssh/ssh_config ssh/ssh_known_hosts /etc/ssh/

RUN	git config --system alias.st status \
&&	git config --system alias.lol "log --graph --decorate --oneline --abbrev-commit --all" \
&&	git config --system commit.verbose true \
&&	git config --system push.default simple \
&&	git config --system --add url."ssh://git@gitlab.com/".insteadOf "https://gitlab.com/" \
&&	git config --system --add url."ssh://git@gitlab.com/".insteadOf "gitlab:" \
&&	git config --system --add url."ssh://git@github.com/".insteadOf "https://github.com/" \
&&	git config --system --add url."ssh://git@github.com/".insteadOf "github:"

ARG	BUILD_DATE
ARG	VCS_REF
ARG	VERSION
LABEL	org.label-schema.build-date=$BUILD_DATE \
	org.label-schema.name="Gopherbase" \
	org.label-schema.description="An overengineered Go development environment in Docker" \
	org.label-schema.url="https://github.com/wjkohnen/dkr-gopherbase/" \
	org.label-schema.vcs-ref=$VCS_REF \
	org.label-schema.vcs-url="https://github.com/wjkohnen/dkr-gopherbase/" \
	org.label-schema.vendor="Johannes Kohnen" \
	org.label-schema.version=$VERSION \
	org.label-schema.schema-version="1.0"
