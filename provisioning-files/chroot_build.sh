#!/bin/bash

apt-get install -y build-essential autoconf libtool git python python3 python3-distutils pkg-config unzip libx11-dev libxext-dev libssl-dev libreadline-dev libncurses5-dev wget
cd /home/vagrant/linux-libs
./linux-libs.sh make bzip2 fftw lua lua52 luajit sdl sdl2 zlib
./linux-libs.sh install bzip2 fftw lua lua52 luajit sdl sdl2 zlib

cd ..
git clone https://github.com/SCons/scons.git
cd scons
python3 bootstrap.py build/scons
cd build/scons
python3 setup.py install
