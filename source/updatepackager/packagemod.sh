#!/bin/bash

#set -vx

pushd source/updatepackager

cp ../Jacob1sMod/build/MSVC/Powder.exe "Jacob1's Mod.exe"
cp ../Jacob1sMod/README readme.txt
cp ../Jacob1sMod/CHANGELOG changelog.txt
cp ../Jacob1sMod/LICENSE license.txt
./packager.exe "Jacob1's Mod.exe" WIN32.ptu
/c/MinGW/msys/1.0/bin/zip.exe -u "Jacob1's Mod ver $1.zip" "Jacob1's Mod.exe" readme.txt changelog.txt license.txt
rm "Jacob1's Mod.exe" readme.txt changelog.txt license.txt

mv ../Jacob1sMod/*log ../../output
mv *.zip ../../output
mv *.ptu ../../output
