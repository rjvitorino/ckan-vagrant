#!/bin/bash

# If you’re installing CKAN for development and want it to be installed in your
# home directory, you can symlink the directories used in this documentation to
# your home directory. This way, you can copy-paste the example commands from this
# documentation without having to modify them, and still have CKAN installed 
# in your home directory:
mkdir -p ~/ckan/lib
sudo ln -s ~/ckan/lib /usr/lib/ckan
mkdir -p ~/ckan/etc
sudo ln -s ~/ckan/etc /etc/ckan

# Create a Python virtual environment (virtualenv) to install CKAN and activate it:
echo "Creating a virtual environment for CKAN..."
sudo mkdir -p /usr/lib/ckan/default
sudo chown `whoami` /usr/lib/ckan/default
virtualenv --no-site-packages /usr/lib/ckan/default
. /usr/lib/ckan/default/bin/activate

# Install CKAN from source and its requirements
echo "Installing CKAN..."
pip install -e 'git+https://github.com/ckan/ckan.git#egg=ckan'
pip install -r /usr/lib/ckan/default/src/ckan/requirements.txt
pip install supervisor
easy_install Pylons

# Reactivate the virtual environment
deactivate
echo "
. /usr/lib/ckan/default/bin/activate
#supervisord" >> ~/.bashrc
source ~/.bashrc

# Create user and databases
echo "Creating Users, Roles and Databases..."
sudo -u postgres psql -c \
"CREATE USER ckan_default WITH PASSWORD 'ckan2014';
ALTER ROLE ckan_default WITH NOSUPERUSER;
ALTER ROLE ckan_default WITH NOCREATEDB;
ALTER ROLE ckan_default WITH NOCREATEROLE;
ALTER ROLE ckan_default WITH NOCREATEUSER;"
sudo -u postgres psql -c \
"CREATE USER datastore_default WITH PASSWORD 'ckan2014';
ALTER ROLE datastore_default WITH NOSUPERUSER;
ALTER ROLE datastore_default WITH NOCREATEDB;
ALTER ROLE datastore_default WITH NOCREATEROLE;
ALTER ROLE datastore_default WITH NOCREATEUSER;"
sudo -u postgres psql -c "CREATE DATABASE ckan_default WITH OWNER ckan_default ENCODING 'utf-8';"
sudo -u postgres psql -c "CREATE DATABASE datastore_default WITH OWNER ckan_default ENCODING 'utf-8';"

echo "Configuring CKAN..."
# Add CKAN schema.xml for Solr
sudo mv /opt/solr/solr/ckan/conf/schema.xml /opt/solr/solr/ckan/conf/schema.xml.bak
sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema-2.0.xml /opt/solr/solr/ckan/conf/schema.xml
sudo service jetty restart

# Create a directory to contain site's config files
sudo mkdir -p /etc/ckan/default
sudo chown -R `whoami` /etc/ckan/

# Create the configuration file
cd /usr/lib/ckan/default/src/ckan

# Repoze.who configuration file needs to be accessible in the same dir as CKAN config file
ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini

# Activate the environment
. /usr/lib/ckan/default/bin/activate
paster make-config ckan /etc/ckan/default/development.ini

# Change the postgres password for ckan
cd /etc/ckan/default
sed -i.bak 's/ckan_default:pass/ckan_default:ckan2014/' development.ini
sed -i.bak 's/datastore_default:pass/datastore_default:ckan2014/' development.ini
sed -i.bak 's/ckan.plugins = stats text_preview recline_preview/ckan.plugins = stats text_preview recline_preview datastore/' development.ini
sed -i.bak 's/#ckan.datastore/ckan.datastore/' development.ini
sed -i.bak 's/ckan.site_url =/ckan.site_url = http:\/\/localhost:5000/' development.ini

# Create database tables
echo "Creating database tables for CKAN..."
cd /usr/lib/ckan/default/src/ckan
paster db init -c /etc/ckan/default/development.ini

# Set permissions
paster --plugin=ckan datastore set-permissions -c /etc/ckan/default/development.ini | sudo -u postgres psql --set ON_ERROR_STOP=1

# Installs supervisord and creates an init.d script
cd && curl https://gist.githubusercontent.com/howthebodyworks/176149/raw/88d0d68c4af22a7474ad1d011659ea2d27e35b8d/supervisord.sh >> supervisord
sed -i.bak 's/usr\/local\/bin\/supervisord/usr\/lib\/ckan\/default\/bin\/supervisord/' supervisord
sudo mv supervisord /etc/init.d/supervisord
sudo chmod +x /etc/init.d/supervisord
sudo touch /etc/supervisord.conf
sudo chmod o+w /etc/supervisord.conf
/usr/lib/ckan/default/bin/echo_supervisord_conf > /etc/supervisord.conf
sudo sed -i.bak 's/pidfile=\/tmp\/supervisord.pid/pidfile=\/var\/run\/supervisord.pid/' /etc/supervisord.conf

# Configures CKAN as a supervisord process 
echo "

[program:ckan]
autostart=true
command=/usr/lib/ckan/default/bin/paster serve /etc/ckan/default/development.ini" >> /etc/supervisord.conf

# Installs CKAN Datapusher
echo "Installing Datapusher..."
pip install -e 'git+https://github.com/ckan/datapusher.git#egg=datapusher'
pip install -r /usr/lib/ckan/default/src/datapusher/requirements.txt

cd /etc/ckan/default
sed -i.bak 's/ckan.plugins = stats text_preview recline_preview datastore/ckan.plugins = stats text_preview recline_preview datastore datapusher/' development.ini
sed -i.bak 's/#ckan.datapusher/ckan.datapusher/' development.ini

echo "

[program:datapusher]
autostart=true
command=/usr/lib/ckan/default/bin/python /usr/lib/ckan/default/src/datapusher/wsgi.py" >> /etc/supervisord.conf

echo "All done, just adding CKAN process as a Supervisor daemon..."
# Sets it to run on boot
sudo chmod o-w /etc/supervisord.conf
sudo update-rc.d supervisord defaults
/etc/init.d/supervisord start
echo "Provisioning complete! You can now access http://localhost:5000/ :)"