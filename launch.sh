#!/bin/bash

URL="starcatcher.us"
rm mod.txt
mod=$?
if [ $mod -ne 0 ]; then
	rm /c/StarHTTP/TPT/Download/Output/{config,error,output}*
	rm  /c/StarHTTP/TPT/Download/Output/*.{zip,ptu}
else
	rm /c/StarHTTP/TPT/mod/Output/{config,error,output}*
	rm /c/StarHTTP/TPT/mod/Output/*.{zip,ptu}
fi

echo grep -o ' ' args.txt | wc -l
#if [ test `grep -o ' ' args.txt | wc -l` -gt 1 ] || true; then
	if [ -f "lock.txt" ]; then
		echo "msg ##jacob1 Error: vagrant is already running" | ./nc.exe -w 1 localhost 9876
		exit 1
	fi
	touch lock.txt
	rm output.txt

	export VAGRANT_HOME="C:\NotProgramFiles\vagrant\files"
	vagrant up
	if [ $mod -ne 0 ]; then
		echo 1
		vagrant ssh -c "pushd The-Powder-Toy/updatepackager && ./compile.sh $(cat args.txt) && ./packager.sh $(cat args.txt) && ./move.sh || (./move.sh && false)" >output.txt 2>&1
	else
		echo 1
		vagrant ssh -c "pushd Jacob1sMod/updatepackager && ./compile.sh $(cat args.txt) && ./packager.sh $(cat args.txt) && ./move.sh || (./move.sh && false)" >output.txt 2>&1
	fi
	success=$?
	vagrant halt
	rm lock.txt
#else
#	if [ $mod -ne 0 ]; then
#		echo "msg #powder-dev Skipping vagrant" | ./nc.exe -w 1 localhost 9876
#	else
#		echo "msg ##jacob1 Skipping vagrant" | ./nc.exe -w 1 localhost 9876
#	fi
#	success=0
#fi

if [ $success -ne 0 ]; then
	if [ $mod -ne 0 ]; then
		mv output/*.log /c/StarHTTP/TPT/Download/Output
		mv output.txt /c/StarHTTP/TPT/Download/Output/vagrantoutput.txt
		echo "msg #powder-dev Build Script Failed, details at https://$URL/TPT/Download/Output" | ./nc.exe -w 1 localhost 9876
	else
		mv output/*.log /c/StarHTTP/TPT/mod/Output
		mv output.txt /c/StarHTTP/TPT/mod/Output/vagrantoutput.txt
		echo "msg ##jacob1 Build Script Failed, details at https://$URL/TPT/mod/Output" | ./nc.exe -w 1 localhost 9876
	fi
else
	if [ $mod -ne 0 ]; then
		./compilemsvc.sh >>output.txt 2>&1
		if [ $? -ne 0 ]; then
			mv source/The-Powder-Toy/*.log /c/StarHTTP/TPT/Download/Output
			mv output.txt /c/StarHTTP/TPT/Download/Output/vagrantoutput.txt
			echo "msg #powder-dev MSVC compile Failed, details at https://$URL/TPT/Download/Output" | ./nc.exe -w 1 localhost 9876
			exit 1
		fi
		source/updatepackager/package.sh >>output.txt 2>&1
		if [ $? -ne 0 ]; then
			mv source/The-Powder-Toy/*.log /c/StarHTTP/TPT/Download/Output
			mv output.txt /c/StarHTTP/TPT/Download/Output/vagrantoutput.txt
			echo "msg #powder-dev MSVC package Failed, details at https://$URL/TPT/Download/Output" | ./nc.exe -w 1 localhost 9876
			exit 1
		fi
		echo "msg #powder-dev Compile Succeeded (pending - https://$URL/TPT/changelog.lua)" | ./nc.exe -w 1 localhost 9876
	else
		./compilemsvcmod.sh >>output.txt 2>&1
		if [ $? -ne 0 ]; then
			mv source/Jacob1sMod/*.log /c/StarHTTP/TPT/mod/Output
			mv output.txt /c/StarHTTP/TPT/mod/Output/vagrantoutput.txt
			echo "msg ##jacob1 MSVC compile Failed, details at https://$URL/TPT/mod/Output" | ./nc.exe -w 1 localhost 9876
			exit 1
		fi
		source/updatepackager/packagemod.sh $(cat args.txt) >>output.txt 2>&1
		if [ $? -ne 0 ]; then
			mv source/Jacob1sMod/*.log /c/StarHTTP/TPT/mod/Output
			mv output.txt /c/StarHTTP/TPT/mod/Output/vagrantoutput.txt
			echo "msg ##jacob1 MSVC package Failed, details at https://$URL/TPT/mod/Output" | ./nc.exe -w 1 localhost 9876
			exit 1
		fi
		echo "msg ##jacob1 Compile Succeeded (pending - https://$URL/TPT/modchangelog.lua)" | ./nc.exe -w 1 localhost 9876
	fi
fi
