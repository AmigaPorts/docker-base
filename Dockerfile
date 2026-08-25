FROM debian:unstable-slim

# START COMMON
LABEL maintainer="Marlon Beijer <marlon@amigadev.com>" \
      version="1.0" \
      description="Base image built on Debian unstable-slim"

COPY deps /tmp/deps

RUN apt update \
	&& apt upgrade -y \
	&& apt install -y \
		genisoimage \
		rsync \
		wget \
		curl \
		git \
		make \
		ninja-build \
		automake \
		nano \
		autoconf \
		pkg-config \
		bsdmainutils \
		zip \
		unzip \
		gawk \
		bison \
		flex\
		netpbm \
		cmake \
		gperf \
		gettext \
		texinfo\
		python3 \
		python3-mako \
		python3-pip \
		g++ \
		gcc \
		gdb \
		build-essential \
		libtool \
		zlib1g-dev \
		zlib1g \
		libpng-dev \
		libx11-dev \
		libxcursor-dev \
		libgl1-mesa-dev \
		libgmpxx4ldbl \
		libgmp-dev \
		libmpfr6 \
		libmpfr-dev \
		libmpc3 \
		libmpc-dev \
		libncurses-dev \
		libswitch-perl \
		libasound2-dev \
		libsdl1.2-dev \
		xutils-dev \
		locales \
		golang \
		sudo \
		xxd \
	&& apt autoremove -y \
	&& apt clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 en_US.UTF-8 \
	&& git config --global user.email "git@amiga.dev" \
	&& git config --global user.name "AmigaDev" \
	&& ln -s /usr/bin/genisoimage /usr/local/bin/mkisofs \
	&& /tmp/deps/lha \
	&& /tmp/deps/ilbmtoicon \
	&& /tmp/deps/flexcat \
	&& /tmp/deps/rust \
	&& rm -rf /tmp/deps \
	&& cd / \
	&& pip3 install --break-system-packages cython \
	&& pip3 install --break-system-packages -U "amitools[vamos] @ git+https://github.com/AmigaPorts/amitools.git" \
	&& for tool in fdtool geotool hunktool rdbtool romtool typetool vamos vamospath vamostool xdfscan xdftool; do command -v "${tool}"; done \
	&& GOPATH=/usr/local go install github.com/github-release/github-release@latest

RUN echo "root:root" | chpasswd
RUN useradd -rm -d /home/jenkins -s /bin/bash -g root -G sudo -u 1001 jenkins
RUN echo 'jenkins:jenkins' | chpasswd
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV LANG=en_US.utf8

WORKDIR /work
