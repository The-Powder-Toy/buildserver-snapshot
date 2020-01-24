#!/bin/bash

if [ -f "lock.txt" ]; then
	echo "Error: vagrant is already running"
	exit 1
fi
touch lock.txt

export VAGRANT_HOME="C:\Starcatcher\Vagrant\files"
#vagrant box update
vagrant up 2>&1 | tee create.txt
vagrant ssh

rm lock.txt
