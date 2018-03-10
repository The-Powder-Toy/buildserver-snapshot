#!/bin/sh

sudo apt-get update
sudo apt-get install -y build-essential git scons cmake pkg-config mingw32 mingw32-binutils mingw32-runtime zip unzip libc6-dev-i386 libx11-dev libxext-dev libssl-dev libreadline-dev libncurses5-dev schroot debootstrap tofrodos genisoimage

cp -r /vagrant/provisioning-files/* .

# 32 bit linux
sudo mkdir /var/chroot
sudo mv chroot_config.txt /etc/schroot/schroot.conf
sudo debootstrap --variant=buildd --arch i386 trusty /var/chroot/ http://archive.ubuntu.com/ubuntu/
sudo mkdir /var/chroot/home/vagrant
chmod +x chroot_build.sh linux-libs/linux-libs.sh
sudo cp -r linux-libs /var/chroot/home/vagrant
sudo mv chroot_build.sh /var/chroot/home/vagrant/chroot_build.sh
sudo chroot /var/chroot /home/vagrant/chroot_build.sh
# Fix permissions and stuff
sudo cp /etc/passwd /var/chroot/etc/passwd
schroot -c trusty -- git clone https://github.com/ThePowderToy/The-Powder-Toy.git
schroot -c trusty -- git clone https://github.com/jacob1/The-Powder-Toy.git Jacob1sMod
sudo chown vagrant -R /var/chroot/home/vagrant

# 64 bit linux
cd linux-libs
chmod +x linux-libs.sh
./linux-libs.sh make bzip2 fftw lua lua52 luajit sdl zlib
sudo ./linux-libs.sh install bzip2 fftw lua lua52 luajit sdl zlib
cd ..

# Windows
cd cross-libs
chmod +x cross-libs.sh
./cross-libs.sh make bzip2 fftw lua lua52 luajit pthread regex sdl zlib
sudo ./cross-libs.sh install bzip2 fftw lua lua52 luajit pthread regex sdl zlib
pushd /usr/lib/gcc/i586-mingw32msvc/4.2.1-sjlj/
i586-mingw32msvc-ar -d libstdc++.a stubs.o
popd
cd ..

# OS X
cd mac
sudo chown vagrant:vagrant -R Powder.app
chmod +x cross-libs.sh
git clone https://github.com/tpoechtrager/osxcross
cd osxcross
#sudo tools/get_dependencies.sh
sudo apt-get install -y clang-3.4 llvm-3.4-dev libxml2-dev uuid-dev libssl-dev bash patch make tar xz-utils bzip2 gzip sed cpio
cp ../MacOSX10.7.sdk.tar.bz2 tarballs
SDK_VERSION=10.7 OSX_VERSION_MIN=10.6 UNATTENDED=1 ./build.sh
cd ..
patch /home/vagrant/mac/osxcross/target/SDK/MacOSX10.7.sdk/usr/include/c++/v1/exception exception.patch
PATH=$PATH:/home/vagrant/mac/osxcross/target/bin
./cross-libs.sh make sdl fftw lua lua52 luajit
sudo ./cross-libs.sh install sdl fftw lua lua52 luajit
git clone https://github.com/hamstergene/libdmg-hfsplus.git
mv nochecksumpatch libdmg-hfsplus
cd libdmg-hfsplus/
git apply nochecksumpatch
cmake CMakeLists.txt -DCMAKE_INSTALL_PREFIX=/usr/local/bin
make
make install
sudo rm /home/vagrant/mac/osxcross/target/SDK/MacOSX10.7.sdk/usr/lib/libSDL-1.2.0.dylib
cd ../..

# Get tpt source, fix some permissions
git clone https://github.com/ThePowderToy/The-Powder-Toy.git
cp -r updatepackager The-Powder-Toy
mkdir "The-Powder-Toy/updatepackager/MacDMG"
sudo cp -r mac/Powder.app "The-Powder-Toy/updatepackager/MacDMG/Powder Snapshot.app"
sudo chown vagrant:vagrant -R The-Powder-Toy
chmod +x The-Powder-Toy/updatepackager/compile.sh The-Powder-Toy/updatepackager/packager.sh The-Powder-Toy/updatepackager/move.sh The-Powder-Toy/updatepackager/updatepackager

# Same as above but for my mod
git clone https://github.com/jacob1/The-Powder-Toy.git Jacob1sMod
cp -r updatepackagermod/* Jacob1sMod/updatepackager
mkdir "Jacob1sMod/updatepackager/MacDMG"
sudo cp -r "mac/Jacob1's Mod.app" "Jacob1sMod/updatepackager/MacDMG/Jacob1's Mod.app"
sudo chown vagrant:vagrant -R Jacob1sMod
chmod +x Jacob1sMod/updatepackager/compile.sh Jacob1sMod/updatepackager/packager.sh Jacob1sMod/updatepackager/move.sh Jacob1sMod/updatepackager/updatepackager
