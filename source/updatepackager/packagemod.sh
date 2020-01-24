#!/bin/bash

#set -vx

grep -q "MSVC" args.txt
if [ $? -eq 0 ]; then
	pushd source/updatepackager

	cp ../Jacob1sMod/build/MSVC/Powder.exe "Jacob1's Mod.exe"
	cp ../Jacob1sMod/README readme.txt
	cp ../Jacob1sMod/CHANGELOG changelog.txt
	cp ../Jacob1sMod/LICENSE license.txt
	./packager.exe "Jacob1's Mod.exe" WIN32.ptu
	powershell Compress-Archive -Path 'Jacob1`'\''s` Mod.exe,readme.txt,changelog.txt,license.txt' -DestinationPath 'Jacob1`'\''s` Mod.zip'
	mv "Jacob1's Mod.zip" "Jacob1's Mod ver $1.zip"
	rm "Jacob1's Mod.exe" readme.txt changelog.txt license.txt

	mv ../Jacob1sMod/*log ../../output
	mv *.zip ../../output
	mv *.ptu ../../output

fi
exit 0
