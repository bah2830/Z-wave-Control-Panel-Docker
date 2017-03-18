FROM ubuntu:xenial
MAINTAINER brentahughes@gmail.com

COPY ozwcp.patch /

# Install some dependencies
RUN apt-get update \
    && apt-get install build-essential git libudev-dev wget -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install openzwave
RUN git clone https://github.com/OpenZWave/open-zwave.git open-zwave \
    && cd open-zwave \
    && make \
    && make install

# Install microhttpd
RUN wget https://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.52.tar.gz \
    && tar zxvf libmicrohttpd-0.9.52.tar.gz \
    && mv libmicrohttpd-0.9.52 libmicrohttpd \
    && cd libmicrohttpd \
    && ./configure \
    && make \
    && make install

# Install openzwave-control-panel
RUN git clone https://github.com/OpenZWave/open-zwave-control-panel.git Openzwave-control-panel \
    && cd Openzwave-control-panel \
    && git apply /ozwcp.patch \
    && sed -i '/# for Mac OS/,+5d' Makefile \
    && sed -i 's/#\(LIBUSB\)/\1/g' Makefile \
    && sed -i 's/#\(LIBS\)/\1/g' Makefile \
    && sed -i -e 's/\(LIBMICROHTTPD\) := .*/\1 := \/usr\/local\/lib\/libmicrohttpd.a/g' Makefile \
    && make \
    && ln -sd ../open-zwave/config

WORKDIR /app/Openzwave-control-panel
CMD ["./ozwcp", "-p", "8008"]