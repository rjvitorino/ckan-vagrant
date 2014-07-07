# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "trusty64"
  
  # This is for Postgresql database ssh connection
  config.vm.network :forwarded_port, guest: 5432, host: 55432
  # This is for Solr ssh connection
  config.vm.network :forwarded_port, guest: 8983, host: 8983
  # This is for CKAN
  config.vm.network :forwarded_port, guest: 5000, host: 5000
  # This is for CKAN Datapusher
  config.vm.network :forwarded_port, guest: 8800, host: 8800
  
  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  config.vm.provision "chef_solo" do |chef|
    chef.cookbooks_path = "cookbooks"
    chef.add_recipe "apt"
    chef.add_recipe "build-essential"
    chef.add_recipe "git"
    chef.add_recipe "java"
    chef.add_recipe "openssl"
    chef.add_recipe "xml"
    chef.add_recipe "python"
    chef.add_recipe "postgresql::server"
  
    # You may also specify custom JSON attributes:
    chef.json = {
      "postgresql" => {
        "password" => {
          "postgres" => ""
        }
      },
      "java" => {
        "install_flavor" => "oracle",
        "jdk_version" => "7",
        "oracle" => {
          "accept_oracle_download_terms" => true
        }
      },
      "run_list" => [ "recipe[postgresql::server]", "recipe[java]" ]
    }
    
  end
  
  # This will install some other things (Solr)
  config.vm.provision "shell",
    path: "provision.sh"
    
  config.vm.provision "shell",
    path: "bootstrap.sh", privileged: false
  
  config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end
  
  config.vm.provider :virtualbox do |vb|
      vb.customize ["modifyvm", :id, "--memory", 1024]
  end

end
