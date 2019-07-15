FROM debian:latest

RUN apt-get update && apt-get install -y --no-install-recommends \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-dev \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-doc \
    gstreamer1.0-tools \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    pulseaudio \
    git \
    apt-transport-https \
    ca-certificates \
    build-essential \
    wget \
    pkg-config

RUN wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz
RUN tar -xvf go1.12.6.linux-amd64.tar.gz
RUN mv go /usr/local

ENV GOROOT /usr/local/go
ENV GOPATH $HOME/go
ENV PATH $GOPATH/bin:$GOROOT/bin:$PATH

ENV GO111MODULE=on
ENV PKG_CONFIG_PATH=/usr/local/opt/libffi/lib/pkgconfig

RUN go mod init github.com/pion/example-webrtc-applications/gstreamer-send
RUN go get github.com/pion/example-webrtc-applications/gstreamer-send

RUN useradd -ms /bin/bash me
USER me

