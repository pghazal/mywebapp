# -*- mode: ruby -*-
# vi: set ft=ruby :

# Inspired from https://gist.github.com/rrosiek/8190550

VAGRANTFILE_API_VERSION = '2'
APPLICATION_NAME = "mywebapp"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 81, host: 8090
  config.vm.hostname = APPLICATION_NAME + ".local"
  config.vm.synced_folder ".", "/var/www/" + APPLICATION_NAME
  config.vm.provision 'shell', :path => "bootstrap.sh", :args => APPLICATION_NAME

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "1024"]
  end

  config.push.define "development", strategy: "ftp" do |push|
    
  end

end
