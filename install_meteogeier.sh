#!/usr/bin/env bash

PACKAGES='mysql-server mysql-client '
AUDIO_GENERATION='sox mgetty-pvftools shntool'

apt-get install -y $PACKAGES $AUDIO_GENERATION

# Install locales (DE)
locale-gen de_DE
locale-gen de_DE.UTF-8

# Perl dependencies
export PERL_MM_USE_DEFAULT=1 
perl -MCPAN -e'install "LWP::Simple"'

# Set up directories
mkdir -p /var/spool/voice/messages
