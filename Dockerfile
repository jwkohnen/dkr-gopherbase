FROM wjkohnen/jessie
MAINTAINER Wolfgang J. Kohnen <wjkohnen@users.noreply.github.com>

CMD	["/usr/sbin/nologin"]

ENV	DEBIAN_FRONTEND noninteractive
RUN	apt-get update \
&&	apt-get install -y \
		vim-tiny- \
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
&&	apt-get autoremove \
&&	apt-get clean \
&&	rm -rf /var/lib/apt/lists/*
ENV	DEBIAN_FRONTEND dialog

RUN     git clone https://github.com/google/protobuf /tmp/protobuf \
&&      cd /tmp/protobuf \
&&      ./autogen.sh \
&&      ./configure \
&&      make -j2 \
&&      make -j2 check \
&&      make install \
&&      ldconfig \
&&      rm -rf /tmp/protobuf

RUN     git clone https://github.com/vim/vim.git /tmp/vim \
&&      cd /tmp/vim \
&&      ./configure \
                --enable-pythoninterp \
                --with-python-config-dir=/usr/lib/python2.7/config-x86_64-linux-gnu \
&&      make \
&&      make install \
&&      rm -rf /tmp/vim \
&&      update-alternatives --install /usr/bin/vi vi /usr/local/bin/vim 100 \
&&      update-alternatives --set vi /usr/local/bin/vim
ENV     EDITOR vim

RUN     git clone https://go.googlesource.com/go /opt/go
RUN     git clone --shared --branch go1.4.3 /opt/go /tmp/go1.4 \
&&      cd /tmp/go1.4/src \
&&      ./make.bash \
&&      cd /opt/go/src \
&&      git checkout release-branch.go1.6 \
&&      GOROOT_BOOTSTRAP=/tmp/go1.4 ./make.bash \
&&      rm -rf /tmp/go1.4 \
&&      find /opt -not -group staff -print0 | xargs --null chgrp staff -- \
&&      find /opt -not -perm -g+w -print0 | xargs --null chmod g+w -- \
&&      mkdir /etc/skel/go \
&&      mkdir /etc/skel/go/src
ENV     GOROOT /opt/go
ENV     PATH $PATH:/opt/go/bin

RUN     GOPATH=/tmp/gotools \
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
&&	GOPATH=/tmp/gotools \
	GOBIN=/usr/local/bin \
	/usr/local/bin/gometalinter --install \
&&      rm -r /tmp/gotools

RUN     mkdir -p /etc/skel/.vim/autoload
RUN     mkdir -p /etc/skel/.vim/bundle
RUN     curl -LSso /etc/skel/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
RUN     git clone https://github.com/fatih/vim-go.git /etc/skel/.vim/bundle/vim-go
RUN     git clone https://github.com/Valloric/YouCompleteMe.git /opt/YouCompleteMe \
&&      cd /opt/YouCompleteMe \
&&      git submodule update --init --recursive \
&&      ./install.py \
&&      find /opt -not -group staff -print0 | xargs --null chgrp staff -- \
&&      find /opt -not -perm -g+w -print0 | xargs --null chmod g+w -- \
&&      ln -s /opt/YouCompleteMe /etc/skel/.vim/bundle/YouCompleteMe
ADD     vimrc /etc/skel/.vimrc

ADD     ssh.tgz /etc/skel/
ADD     bashrc /etc/skel/.bashrc
