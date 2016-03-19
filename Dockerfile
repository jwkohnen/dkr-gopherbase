FROM wjkohnen/jessie
MAINTAINER Wolfgang J. Kohnen <wjkohnen@users.noreply.github.com>

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

CMD	["/usr/sbin/nologin"]
