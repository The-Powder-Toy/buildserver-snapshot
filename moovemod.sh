#!/bin/bash

pushd output
mv ../source/Jacob1sMod/*.log /c/StarHTTP/TPT/mod/Output
mv *.log /c/StarHTTP/TPT/mod/Output
logsexist=$?
if [ $logsexist -ne 0 ]; then
	echo "msg ##jacob1 Mod changelogs changed" | ./nc.exe -w 1 localhost 9876
	exit 0
fi

mv ../output.txt /c/StarHTTP/TPT/mod/Output/vagrantoutput.txt
cp *.{zip,dmg} "/c/StarHTTP/TPT/mod/Older/"
rm /c/StarHTTP/TPT/mod/*.{zip,dmg}
mv *.{zip,dmg} /c/StarHTTP/TPT/mod/
for f in /c/StarHTTP/TPT/mod/*.{zip,dmg}; do mv "$f" "$(echo "$f" | sed -e 's/ ver [0-9]\+\.[0-9]\+//')"; done
mv *.ptu /c/StarHTTP/TPT/mod/
success=$?
popd

if [ $success -ne 0 ]; then
	echo "msg ##jacob1 Moving update files failed" | ./nc.exe -w 1 localhost 9876
else
	echo "msg ##jacob1 Mod update released!" | ./nc.exe -w 1 localhost 9876
fi