FROM ubuntu:trusty
MAINTAINER Wolfgang Johannes Kohnen <wjkohnen@users.noreply.github.com>
CMD ["/bin/bash"]

# http://stackoverflow.com/a/26217767/2715936 !?!?
ENV 	DEBIAN_FRONTEND noninteractive
RUN	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true \
		| /usr/bin/debconf-set-selections \
&&	echo tzdata tzdata/Zones/Etc select UTC | debconf-set-selections \
&&	echo debconf debconf/priority select critical | debconf-set-selections \
&&	echo debconf debconf/frontend select readline | debconf-set-selections \
&&	echo debconf debconf/frontend seen false | debconf-set-selections \
&&	dpkg-reconfigure tzdata \
&&	locale-gen en_US.UTF-8 \
&&	dpkg-reconfigure locales \
&&	locale -a
ENV	LANG=en_US.UTF-8

ADD	sources.list /etc/apt/
RUN	apt-get update \
&& 	apt-get -fy dist-upgrade \
&&	apt-get install -y debconf \
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
&&	apt-key adv \
		--keyserver hkp://keyserver.ubuntu.com:80 \
		--recv-keys \
			3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
			E1DD270288B4E6030699E45FA1715D88E1DF1F24  \
&&	add-apt-repository ppa:fkrull/deadsnakes -y  \
&&	add-apt-repository ppa:rwky/nodejs -y \
&&	echo "deb http://download.mono-project.com/repo/debian wheezy main" > \
		/etc/apt/sources.list.d/mono-xamarin.list  \
&&	echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" > \
		/etc/apt/sources.list.d/webupd8team-java.list \
&&	apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 \
		--recv-keys EEA14886  \
&&	apt-get update \
&&	apt-get install -y \
		maven \
		python3.5 \
		nodejs \
		mono-complete \
		oracle-java8-set-default \
&&	apt-get autoremove \
&&	apt-get clean \
&&	rm -rf /var/lib/apt/lists/*
ENV	DEBIAN_FRONTEND dialog

RUN	git clone https://github.com/google/protobuf /tmp/protobuf \
&&	cd /tmp/protobuf \
&&	./autogen.sh \
&&	./configure \
&&	make \
&&	make check \
&&	make install \
&&	ldconfig \
&&	rm -rf /tmp/protobuf

RUN	git clone https://github.com/vim/vim.git /tmp/vim \
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

RUN	mkdir -p /etc/skel/.vim/autoload \
&&	mkdir -p /etc/skel/.vim/bundle \
&&	curl -LSso /etc/skel/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim \
&&	git clone https://github.com/fatih/vim-go.git /etc/skel/.vim/bundle/vim-go \
&&	git clone https://github.com/Valloric/YouCompleteMe.git /opt/YouCompleteMe  \
&&	cd /opt/YouCompleteMe \
&&	git submodule update --init --recursive \
&&	./install.py \
&&	find /opt -not -group staff -print0 | xargs --null chgrp staff -- \
&&	find /opt -not -perm -g+w -print0 | xargs --null chmod g+w -- \
&&	ln -s /opt/YouCompleteMe /etc/skel/.vim/bundle/YouCompleteMe
ADD	vimrc /etc/skel/.vimrc

# download go source and build 1.4 for bootstrapping
RUN	git clone https://go.googlesource.com/go /usr/local/go-tip \
&&	git clone --shared --branch go1.4.3 /usr/local/go-tip /usr/local/go1.4 \
&&	cd /usr/local/go1.4/src \
&&	CGO_ENABLED=0 ./make.bash

# build current release into /usr/local/go using 1.4 for bootstrap
ENV	_DKR_GO_RELEASE 1.7
ENV	_DKR_BUMP 2016-11-12
RUN	git clone --branch release-branch.go${_DKR_GO_RELEASE} --reference /usr/local/go-tip https://go.googlesource.com/go /usr/local/go \
&&	cd /usr/local/go/src \
&&	GOROOT_BOOTSTRAP=/usr/local/go1.4 ./make.bash
ENV	PATH $PATH:/usr/local/go/bin

# build tip into go-tip, using current release as bootstrap
ENV	_DKR_BUMP 2016-11-12
RUN	cd /usr/local/go-tip/src \
&&	git pull \
&&	git checkout master \
&&	GOROOT_BOOTSTRAP=/usr/local/go ./make.bash

# cache some go runtimes
RUN	GOOS=windows /usr/local/go/bin/go install -v std \
&&	GOOS=darwin /usr/local/go/bin/go install -v std \
&&	GOARCH=386 /usr/local/go/bin/go install -v std \
&&	/usr/local/go/bin/go install -v -race std

RUN	find /usr/local/ -not -group staff -print0 | xargs --null chgrp staff -- \
&&	find /usr/local/ -not -perm -g+w -print0 | xargs --null chmod g+w --

RUN	GOPATH=/tmp/gotools \
	GOBIN=/usr/local/bin \
	go get -v \
		golang.org/x/tools/cmd/... \
		github.com/nsf/gocode \
		github.com/rogpeppe/godef \
		github.com/golang/lint/golint \
		github.com/jstemmer/gotags \
		github.com/garyburd/go-explorer/src/getool \
		github.com/alecthomas/gometalinter \
		github.com/klauspost/asmfmt \
		github.com/fatih/motion \
		github.com/zmb3/gogetdoc \
		github.com/derekparker/delve/cmd/dlv \
&&	GOPATH=/tmp/gotools \
	GOBIN=/usr/local/bin \
	/usr/local/bin/gometalinter --install \
&&	rm -r /tmp/gotools

COPY	ssh/config /etc/ssh/ssh_config
COPY	ssh/known_hosts /etc/ssh/ssh_known_hosts
RUN	mkdir /etc/skel/.ssh
RUN	chmod 700 /etc/skel/.ssh
