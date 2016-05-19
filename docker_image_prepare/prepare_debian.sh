#!/bin/bash

echo "10.100.24.227 nl20droid2" >> /etc/hosts
cp -a /scripts/ssh_config ~/.ssh/
chmod 700 ~/.ssh

apt-get update 
apt-get -y install \
           build-essential \
           git \
           ruby \
           tar \
           gzip \
           texinfo \
           bison \
           flex \
           vim
apt-get -y install libmpfr-dev libgmp-dev libmpc-dev
apt-get -y install dejagnu
apt-get -y upgrade

git clone ssh://arc_gnu_tester@nl20droid2/home/arc_gnu_tester/source/docker_toolchain_tools /scripts_new
