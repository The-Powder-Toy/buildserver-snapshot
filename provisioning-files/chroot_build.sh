#!/bin/bash

apt-get install -y build-essential autoconf libtool git python3 python3-setuptools pkg-config unzip libx11-dev libxext-dev libssl-dev libreadline-dev libncurses5-dev wget vim
cd /home/vagrant/linux-libs
./linux-libs.sh make bzip2 fftw lua lua52 luajit sdl2 zlib curl
./linux-libs.sh install bzip2 fftw lua lua52 luajit sdl2 zlib curl

cd ..
git clone https://github.com/SCons/scons.git
cd scons
python3 bootstrap.py build/scons
cd build/scons
python3 setup.py install

# scons looks for "python" even though it was built with python 3
ln -s /usr/bin/python3 /usr/local/bin/python
