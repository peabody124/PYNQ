#!/bin/bash
set -x
script_dir=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)

# This script sets up a Ubuntu host to be able to create the image by
# installing all of the necessary files. It assumes an EC2 host with
# passwordless sudo

# Install a bunch of packages we need

read -d '' PACKAGES <<EOT
bc
libtool-bin
gperf
bison
flex
texi2html
texinfo
help2man
gawk
libtool
build-essential
automake
libncurses5-dev
libz-dev
libglib2.0-dev
device-tree-compiler
qemu-user-static
binfmt-support
multistrap
git
lib32z1
lib32ncurses5
lib32stdc++6
libgnutls28-dev
libssl-dev
kpartx
dosfstools
nfs-common
zerofree
u-boot-tools
rpm2cpio
qemu
EOT
set -e

sudo apt-get install -y $PACKAGES

# Install up-to-date versions of crosstool and qemu
if [ -e tools ]; then
  rm -rf tools
fi

mkdir tools
cd tools/

wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.23.0.tar.bz2
tar -xf crosstool-ng-1.23.0.tar.bz2
cd crosstool-ng-1.23.0/
./configure --prefix=/opt/crosstool-ng
make
sudo make install
cd ..

# Create gmake symlink to keep SDK happy
cd /usr/bin
if ! which gmake
then
  sudo ln -s make gmake
fi

echo 'PATH=/opt/qemu/bin:/opt/crosstool-ng/bin:$PATH' >> ~/.profile

echo "Now install Vivado, SDx, and Petalinux."
echo "Re-login to  ensure the enviroment is properly set up."
