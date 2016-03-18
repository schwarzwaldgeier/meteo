#!/usr/bin/env bash
WWW_USER=vagrant

PACKAGES='apache2 git vim'

apt-get update && apt-get install -y $PACKAGES
if ! [ -L /var/www ]; then
  echo 'INFO: It seems /var/www is not right. Linking /var/www to /vagrant ...'
  rm -rf /var/www
  ln -fs /vagrant /var/www
fi
