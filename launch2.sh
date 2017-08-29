#!/bin/bash

if [ -f "lock.txt" ]; then
	echo "Error: vagrant is already running"
	exit 1
fi
touch lock.txt

export VAGRANT_HOME="C:\NotProgramFiles\vagrant\files"
#vagrant box update
vagrant up > output.txt
vagrant ssh

rm lock.txt
