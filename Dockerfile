FROM    ubuntu:18.04
LABEL   maintainer="caobing <caobing@cowarobot.com>"
ENV     DEBIAN_FRONTEND="noninteractive"
ENV     TZ=Asia/Shanghai
WORKDIR /aptly

RUN sed -i s@archive.ubuntu.com@mirrors.aliyun.com@g /etc/apt/sources.list
RUN sed -i s@security.ubuntu.com@mirrors.aliyun.com@g /etc/apt/sources.list

RUN apt-get update ;\
    apt-get -y --no-install-recommends install \
      aptly \
      gnupg \
      gpg-agent \
      ca-certificates \
      sudo \
      inotify-tools \
      vim

RUN groupadd -g 1010 aptly;\
    useradd -u 1010 -g 1010 aptly -s /bin/bash -d /aptly ;

RUN apt-get -y autoremove && apt-get -y autoclean && rm -rf /var/lib/apt/lists/*

EXPOSE 8080

