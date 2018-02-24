#!/bin/bash

export VER="$1"
shift

LIN32_package()
{
	cp /var/chroot/home/vagrant/The-Powder-Toy/build/$1/powder powder
	cp ../{README.md,LICENSE} .
	./updatepackager powder $1.ptu
	zip -u "Snapshot linux32.zip" powder README.md LICENSE
	rm powder README LICENSE
}

LIN64_package()
{
	cp ../build/$1/powder64 powder64
	cp ../{README.md,LICENSE} .
	./updatepackager powder64 $1.ptu
	zip -u "Snapshot linux64.zip" powder64 README.md LICENSE
	rm powder64 README LICENSE
}

WIN32_package()
{
	cp ../build/$1/Powder.exe Powder.exe
	cp ../README readme.txt
	cp ../LICENSE license.txt
	todos {readme,license}.txt
	./updatepackager Powder.exe $1.ptu
	zip -u "Snapshot.zip" Powder.exe readme.txt license.txt
	rm Powder.exe readme.txt license.txt
}

MACOSX_package()
{
	cp ../build/$1/powder-x powder-x
	cp ../{README.md,LICENSE} MacDMG
	./updatepackager powder-x $1.ptu
	mv powder-x "MacDMG/Powder Snapshot.app/Contents/MacOS"
	genisoimage -D -V "The-Powder-Toy Snapshots" -no-pad -r -apple -o powder-osx-uncompressed.dmg "MacDMG"
	dmg dmg powder-osx-uncompressed.dmg Snapshot.dmg
	rm powder-osx-uncompressed.dmg "MacDMG/Powder Snapshot.app/Contents/MacOS/powder-x" MacDMG/{README.md,LICENSE}
}

MSVC_package()
{
	touch WIN32.ptu
}

for plat in "$@"
do
	${plat}_package $plat
done
