FROM ubuntu:19.04

# START COMMON
MAINTAINER Marlon Beijer "marlon@amigadev.com"

RUN dpkg --add-architecture i386 && \
        apt update && \
        apt install -y python-pip \
        genisoimage \
        rsync \
        wget \
        curl \
        git \
        make \
        automake \
        autoconf \
        pkg-config \
        unzip \
        gawk \
        bison \
        flex\
        netpbm \
        cmake \
        gperf \
        gettext \
        texinfo\
        python \
        python-mako \
        g++ \
        gcc \
        gcc-multilib \
        g++-multilib \
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
        libc6:i386 \
        libstdc++6:i386

RUN git config --global user.email "you@example.com" && \
        git config --global user.name "Your Name"

RUN echo "root:root" | chpasswd

RUN ln -s /usr/bin/genisoimage /usr/local/bin/mkisofs

# Install proper LHA
RUN cd /tmp/ && git clone https://github.com/AmigaPorts/lha.git && cd lha && autoreconf -is && ./configure && make && make check && make install

# Install xdftool
RUN pip install amitools

WORKDIR /work
