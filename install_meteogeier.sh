#!/usr/bin/env bash

PACKAGES='mysql-server mysql-client sox'

apt-get install -y $PACKAGES

# Install locales (DE)
sudo locale-gen de_DE
sudo locale-gen de_DE.UTF-8
