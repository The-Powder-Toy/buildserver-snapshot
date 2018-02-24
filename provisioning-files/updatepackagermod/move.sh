#!/bin/bash

if [ -f "/var/chroot/home/vagrant/Jacob1sMod/config.log" ]; then
	mv /var/chroot/home/vagrant/Jacob1sMod/config.log /vagrant/output/config_LIN32.log
fi
mv ../*.log /vagrant/output
mv *.{zip,dmg} /vagrant/output
mv *.ptu /vagrant/output
