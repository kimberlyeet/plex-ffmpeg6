# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-ubuntu:noble

# set version label
ARG BUILD_DATE
ARG VERSION
ARG PLEX_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

#Add needed nvidia environment variables for https://github.com/NVIDIA/nvidia-docker
ENV NVIDIA_DRIVER_CAPABILITIES="compute,video,utility,graphics"

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive" \
  PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server-new" \
  PLEX_ARCH="amd64" \
  PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
  PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
  PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
  PLEX_MEDIA_SERVER_USER="abc" \
  PLEX_MEDIA_SERVER_INFO_VENDOR="Docker" \
  PLEX_MEDIA_SERVER_INFO_DEVICE="Docker Container (LinuxServer.io)" \
  TMPDIR=/run/plex-temp

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y \
    udev \
    wget && \
  echo "**** install plex ****" && \
  curl -o \
    /tmp/plexmediaserver.deb -L \
    "https://artifacts.plex.tv/plex-media-server-experimental/1.42.0.10006-6b8dab7d0/debian/plexmediaserver_1.42.0.10006-6b8dab7d0_amd64.deb" && \
  dpkg -i /tmp/plexmediaserver.deb && \
  echo "**** ensure abc user's home folder is /app ****" && \
  usermod -d /app abc && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /etc/default/plexmediaserver \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

# add unrar
COPY --from=unrar /usr/bin/unrar-ubuntu /usr/bin/unrar

# ports and volumes
EXPOSE 32400/tcp 1900/udp 5353/udp 8324/tcp 32410/udp 32412/udp 32413/udp 32414/udp 32469/tcp
VOLUME /config
