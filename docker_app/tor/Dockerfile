FROM ubuntu:jammy

RUN apt update -y && \
    apt install -y curl git wget build-essential libzstd-dev liblzma-dev \
    libnss3-dev lsb-release software-properties-common gnupg libssl-dev \
    zlib1g zlib1g-dev autoconf libevent-dev;

WORKDIR /tmp
RUN wget https://apt.llvm.org/llvm.sh -O /tmp/llvm.sh && bash /tmp/llvm.sh 17;
RUN git clone -b tor-0.4.7.13 --depth 1 https://gitlab.torproject.org/tpo/core/tor tor;

WORKDIR /tmp/tor
RUN ./autogen.sh;
RUN CC=clang-17 CXX=clang++-17 ./configure --enable-zstd --enable-lzma --disable-asciidoc;
RUN make -j$(nproc);
RUN make install;

WORKDIR /
RUN apt purge -y curl git wget build-essential software-properties-common \
    gnupg clang-17 && rm -rf /tmp/tor;

RUN mkdir -pv /var/lib/tor/data && \
    chown -R 1500:1500 /var/lib/tor && \
    chmod -R 755 /var/lib && \
    chmod -R 700 /var/lib/tor

CMD [ "/usr/local/bin/tor", "-f", "/var/lib/tor/torrc" ]
