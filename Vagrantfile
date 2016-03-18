# -*- mode: ruby -*-
# vi: set ft=ruby :
#
CONFIG_FILE_DEV = "vagrant-dev.rb"
#a slug


# The required config file are a directory higher, thats why ../ is prepended to
# require_relative function call
if File.exist?(CONFIG_FILE_DEV)
    puts "DEVELOPMENT: Loading settings from: #{CONFIG_FILE_DEV}"
    require_relative "#{CONFIG_FILE_DEV}"
end

# Default configs (override in config file only)
PRODUCTION_MODE=true if not defined? (PRODUCTION_MODE)
USE_GUI=false if not defined? (USE_GUI)
PROJECT_NAME='meteogeier' if not defined? (PROJECT_NAME)
MAIN_CPU_COUNT=1 if not defined? (MAIN_CPU_COUNT)
MAIN_HOSTNAME="meteo.vm" if not defined? (MAIN_HOSTNAME)
MAIN_RAM=1024 if not defined? (MAIN_RAM)
MAIN_IP_ADDR='192.168.10.157' if not defined? (MAIN_IP_ADDR)
MAIN_GATEWAY='192.168.10.254' if not defined? (MAIN_GATEWAY)
EXTRA_PROVISION_SCRIPT='install_meteogeier.sh' if not defined? (EXTRA_PROVISION_SCRIPT)

puts "PRODUCTION_MODE: #{PRODUCTION_MODE}"
puts "USE_GUI: #{USE_GUI}"

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
    config.vm.provider :virtualbox do |vb| 
        vb.gui = USE_GUI 
    end

    config.vm.define "main", primary: true do |main|
        main.vm.box = "ubuntu/trusty64"
        main.vm.box_url = "http://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
        config.vm.provider :virtualbox do |vb| 
            vb.name = PROJECT_NAME
            vb.customize ["modifyvm", :id, "--memory", MAIN_RAM]
            vb.customize ["modifyvm", :id, "--ioapic", "on"]
            vb.customize ["modifyvm", :id, "--cpus", MAIN_CPU_COUNT]
        end
        main.vm.hostname=MAIN_HOSTNAME

        if PRODUCTION_MODE == true
            # In production mode configure a 'public' ip addres and configure
            # the fucking gateway when provisioning. Don't forget to provision!
            config.vm.network :public_network, ip: MAIN_IP_ADDR
            default_router = MAIN_GATEWAY
            # change/ensure the default route via the local network's WAN router, 
            # useful for public_network/bridged mode
            config.vm.provision :shell, :inline => "echo 'Network POSCONFIG'; ip route delete default || true; ip route add default via #{default_router}"
        else
            # If not, just use the provided ip address for the private network
            main.vm.network :private_network, ip: MAIN_IP_ADDR
        end

        main.vm.provision :shell, :path => "bootstrap_web_server.sh"
        if defined? (EXTRA_PROVISION_SCRIPT)
            puts "INFO: Running extra provision: #{EXTRA_PROVISION_SCRIPT}"
            main.vm.provision :shell, :path => "#{EXTRA_PROVISION_SCRIPT}"
        else
            puts "INFO: No extra provision defined"
        end
    end 
end
