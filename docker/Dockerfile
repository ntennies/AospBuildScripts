FROM ubuntu:14.04
ARG userid
ARG groupid
ARG username

RUN apt-get update && apt-get install -y git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip python openjdk-7-jdk

RUN apt-get install -y bc vim minicom screen emacs device-tree-compiler

RUN apt-get install -y sudo

RUN apt-get install -y software-properties-common && add-apt-repository -y ppa:deadsnakes/ppa && apt update && apt-get install -y python3.6

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.6 2
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.4 1

RUN curl -o jdk8.tgz https://android.googlesource.com/platform/prebuilts/jdk/jdk8/+archive/master.tar.gz \
 && tar -zxf jdk8.tgz linux-x86 \
 && mv linux-x86 /usr/lib/jvm/java-8-openjdk-amd64 \
 && rm -rf jdk8.tgz

COPY ./repo /usr/local/bin/repo

RUN echo "e5b9de1ac289f7e25536b5cd41f4fa8f7a824719e0116c970210d1cd42e68da4 /usr/local/bin/repo" | sha256sum --strict -c - \
 && chmod a+x /usr/local/bin/repo

RUN groupadd -g $groupid $username \
 && adduser --uid $userid --gid $groupid --disabled-password $username \
 && echo $username > /root/username \
 && adduser $username sudo \
 && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers \
 && echo "export USER="$username >>/home/$username/.gitconfig
COPY gitconfig /home/$username/.gitconfig
RUN chown $userid:$groupid /home/$username/.gitconfig
ENV HOME=/home/$username
ENV USER=$username

ENTRYPOINT chroot --userspec=$(cat /root/username):$(cat /root/username) / /bin/bash -i
