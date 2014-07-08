## About

This project contains the necessary files and guides to setup CKAN on a Vagrant box.
The setup was based on the **[official guide](https://github.com/ckan/ckan/wiki/How-to-Install-CKAN-on-an-Ubuntu-10.04-Vagrant-Virtual-Machine)** on how to install CKAN on an Ubuntu Vagrant Virtual Machine. It installs latest CKAN release, with [DataStore](http://docs.ckan.org/en/latest/maintaining/datastore.html) and [DataPusher](http://docs.ckan.org/projects/datapusher/en/latest/) extensions.

---

### Disclaimer

This project is **not to be used on a production environment**! It was created to quickly provide a virtual environment to developers/managers that want to work with CKAN and don't need the hassle of configuring a server or installing all the required packages on their machine.

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

---

### Next steps

- [Register](http://localhost:5000/user/register) an Account (you'll need the generated private API Key to use CKAN and CKAN DataStore APIs);
- If you want **admin** access on CKAN with your account please run the following commands, replacing `<your_username>` with the username you chose when creating the account, of course:

	```
	vagrant ssh
	cd /usr/lib/ckan/default/src/ckan
	paster sysadmin add <your_username> -c /etc/ckan/default/development.ini
	logout
	```

---

### Issues/Troubleshooting

Feel free to contact me or create a new issue on this repository.
I'll do my best to try and help!