#!/usr/bin/env bash

PACKAGES='mysql-server mysql-client sox'

apt-get install -y $PACKAGES
#if ! [ -L /var/www ]; then
  #rm -rf /var/www
  #ln -fs /vagrant /var/www
#fi
