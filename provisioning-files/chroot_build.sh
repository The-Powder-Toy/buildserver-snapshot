#!/bin/bash

apt-get install -y build-essential git scons pkg-config unzip libx11-dev libxext-dev libreadline-dev libncurses5-dev wget
cd /home/vagrant/linux-libs
./linux-libs.sh make bzip2 fftw lua lua52 luajit sdl zlib
./linux-libs.sh install bzip2 fftw lua lua52 luajit sdl zlib