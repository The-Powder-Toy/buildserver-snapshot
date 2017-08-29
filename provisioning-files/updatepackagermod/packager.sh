#!/bin/bash

export VER="$1"
shift

LIN32_package()
{
	cp /var/chroot/home/vagrant/Jacob1sMod/build/$1/powder "Jacob1's Mod"
	cp ../{README,LICENSE} .
	./updatepackager "Jacob1's Mod" $1.ptu
	zip -u "Jacob1's Mod ver $VER linux32.zip" "Jacob1's Mod" README LICENSE
	rm "Jacob1's Mod" README LICENSE
}

LIN64_package()
{
	cp ../build/$1/powder64 "Jacob1's Mod"
	cp ../{README,LICENSE} .
	./updatepackager "Jacob1's Mod" $1.ptu
	zip -u "Jacob1's Mod ver $VER linux64.zip" "Jacob1's Mod" README LICENSE
	rm "Jacob1's Mod" README LICENSE
}

WIN32_package()
{
	cp ../build/$1/Powder.exe "Jacob1's Mod.exe"
	cp ../README readme.txt
	cp ../LICENSE license.txt
	todos {readme,license}.txt
	./updatepackager "Jacob1's Mod.exe" $1.ptu
	zip -u "Jacob1's Mod ver $VER.zip" "Jacob1's Mod.exe" readme.txt
	rm "Jacob1's Mod.exe" readme.txt
}

MACOSX_package()
{
	cp ../build/$1/powder-x powder-x
	cp ../{README,LICENSE} MacDMG
	./updatepackager powder-x $1.ptu
	mv powder-x "MacDMG/Jacob1's Mod.app/Contents/MacOS"
	genisoimage -D -V "Jacob1's Mod" -no-pad -r -apple -o powder-osx-uncompressed.dmg "MacDMG"
	dmg dmg powder-osx-uncompressed.dmg "Jacob1's Mod ver $VER.dmg"
	rm powder-osx-uncompressed.dmg "MacDMG/Jacob1's Mod.app/Contents/MacOS/powder-x" MacDMG/{README,LICENSE}
}

MSVC_package()
{
	touch WIN32.ptu
}

for plat in "$@"
do
	${plat}_package $plat
done
