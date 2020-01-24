#!/bin/bash

#set -vx

grep -q "MSVC" args.txt
if [ $? -eq 0 ]; then
	echo "msg ##jacob1 Vagrant compile succeeded, starting msvc compile" | ./nc.exe -w 1 localhost 9876
	pushd source/Jacob1sMod
	git pull
	if test $? -ne 0; then
		echo "msg ##jacob1 Error, could not update source" | ../../nc.exe -w 1 localhost 9876
		exit 1
	fi
	echo "$(git rev-parse HEAD)" > latest_MSVC.log
	scons --clean
	export VER=$(cat ../../args.txt | cut -d" " -f 1)
	export COMPILE="env CPPDEFINES=UPDATESERVER=\\\"starcatcher.us/TPT\\\" scons --msvc --static --luajit --release -j3"
	$COMPILE --win --builddir=build/MSVC 2> error_MSVC.log 1> output_MSVC.log
	ret=$?
	if test $ret -ne 0; then
		#echo "msg ##jacob1 test1 please ignore" | ../../nc.exe -w 1 localhost 9876
		if grep -Fq "program database" output_MSVC.log || grep -Fq "cannot open program database" output_MSVC.log; then
			sleep 5
			echo "msg ##jacob1 msvc compiler fail, retrying" | ../../nc.exe -w 1 localhost 9876
			scons --clean
			$COMPILE --win --builddir=build/MSVC 2> error_MSVC.log 1> output_MSVC.log
			ret=$?
		fi
	fi
	mv config.log config_MSVC.log
	popd
	exit $ret
fi
exit 0
