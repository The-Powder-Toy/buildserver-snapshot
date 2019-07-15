#!/bin/bash

#set -vx

grep -q "MSVC" args.txt
if [ $? -eq 0 ]; then
	pushd source/updatepackager

	cp ../The-Powder-Toy/build/MSVC/Powder.exe Powder.exe
	cp ../The-Powder-Toy/README.md readme.txt
	cp ../The-Powder-Toy/LICENSE license.txt
	./packager.exe Powder.exe WIN32.ptu
	powershell Compress-Archive -Path Powder.exe,readme.txt,license.txt -DestinationPath Snapshot.zip
	rm Powder.exe readme.txt license.txt

	mv ../The-Powder-Toy/*log ../../output
	mv *.zip ../../output
	mv *.ptu ../../output
fi
exit 0
