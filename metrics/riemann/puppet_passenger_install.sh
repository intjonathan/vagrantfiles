apt-get -y install apache2 ruby1.9.1-dev
apt-get -y install apache2-threaded-dev libapr1-dev libaprutil1-dev
sudo a2enmod ssl
sudo a2enmod headers
sudo a2enmod socache_shmcb
service apache2 restart
sudo gem install rack passenger
yes | passenger-install-apache2-module

sudo mkdir -p /usr/share/puppet/rack/puppetmasterd
sudo mkdir /usr/share/puppet/rack/puppetmasterd/public /usr/share/puppet/rack/puppetmasterd/tmp
sudo cp /usr/share/puppet/ext/rack/config.ru /usr/share/puppet/rack/puppetmasterd/
sudo chown puppet:puppet /usr/share/puppet/rack/puppetmasterd/config.ru