#!/bin/bash

if [ -f "/var/chroot/home/vagrant/The-Powder-Toy/config.log" ]; then
	mv /var/chroot/home/ubuntu/The-Powder-Toy/config.log /vagrant/output/config_LIN32.log
fi
mv ../*.log /vagrant/output
mv *.{zip,dmg} /vagrant/output
mv *.ptu /vagrant/output
