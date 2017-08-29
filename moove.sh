#!/bin/bash

pushd output
mv ../source/The-Powder-Toy/*.log /c/StarHTTP/TPT/Download/Output
mv *.log /c/StarHTTP/TPT/Download/Output
logsexist=$?
if [ $logsexist -ne 0 ]; then
	echo "msg ##jacob1 Changelogs changed" | ../nc.exe -w 1 localhost 9876
	exit 0
fi

mv ../output.txt /c/StarHTTP/TPT/Download/Output/vagrantoutput.txt
cp "Snapshot linux32.zip" "/c/StarHTTP/TPT/Download/Older/Snapshot $1 linux32.zip"
cp "Snapshot linux64.zip" "/c/StarHTTP/TPT/Download/Older/Snapshot $1 linux64.zip"
cp "Snapshot.dmg" "/c/StarHTTP/TPT/Download/Older/Snapshot $1.dmg"
cp "Snapshot.zip" "/c/StarHTTP/TPT/Download/Older/Snapshot $1.zip"
mv *.{zip,dmg} /c/StarHTTP/TPT/Download/
mv *.ptu /c/StarHTTP/TPT/Download/
success=$?
popd

if [ $success -ne 0 ]; then
	echo "msg ##jacob1 Moving update files failed" | ./nc.exe -w 1 localhost 9876
else
	echo "msg #powder-dev Snapshot update $1 released!" | ./nc.exe -w 1 localhost 9876
fi