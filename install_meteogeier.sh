#!/usr/bin/env bash

AUDIO_GENERATION='sox mgetty-pvftools shntool'

apt-get install -y $AUDIO_GENERATION

# Install locales (DE)
locale-gen de_DE
locale-gen de_DE.UTF-8

# Perl dependencies
export PERL_MM_USE_DEFAULT=1 
perl -MCPAN -e'install "LWP::Simple"'

# Set up directories
mkdir -p /var/spool/voice/messages
chmod 777 /var/spool/voice/messages

# Link crontab
ln -sf /var/www/crontab /var/spool/cron/crontabs/root
