## About

This project contains the necessary files and guides to setup CKAN on a Vagrant box.
The setup was based on the **[official guide](https://github.com/ckan/ckan/wiki/How-to-Install-CKAN-on-an-Ubuntu-10.04-Vagrant-Virtual-Machine)** on how to install CKAN on an Ubuntu Vagrant Virtual Machine.

---

### Requirements

- **VirtualBox** - [https://www.virtualbox.org/](https://www.virtualbox.org/)
- **Vagrant** - [http://www.vagrantup.com/](http://www.vagrantup.com/)

---

### Setup

After installing the requirements (check their documentation for any issues or doubts), start by adding an updated **Ubuntu Server** virtual box (in this case `14.04 LTS`) .

```
vagrant box add trusty64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
```

Fetch the submodules (Vagrant cookbooks) required for the setup...

```
git submodule init
git submodule update
```

Start the vagrant (it will take around 10 to 15 minutes to install everything so feel free to take a walk or have a coffee meanwhile):

```
vagrant up
```

You can ignore the last errors regarding the connection with Solr, but please check if there's anything unusual in the logs.

And that's it! Head to [http://localhost:5000/](http://localhost:5000/) and start using CKAN :)
