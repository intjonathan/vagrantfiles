#! /bin/bash

#Source the distro release name and version as environment variables:
. /etc/lsb-release

if [ ! -f /home/vagrant/repos_added.txt ];
then    
  sudo wget -N http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb
  sudo dpkg -i puppetlabs-release-${DISTRIB_CODENAME}.deb
  sudo apt-get update
  #Touch the repos_added file to skip this block the next time around
  touch /home/vagrant/repos_added.txt

else
	echo "Skipping repo addition and package installation..."
fi

if [ ! -f /home/vagrant/puppet_master_installed.txt ];
then
	sudo apt-get -y install puppet
	sudo service ufw stop

  sudo cat > /etc/puppet/puppet.conf <<"EOF"
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN.
ssl_client_verify_header = SSL_CLIENT_VERIFY
environmentpath = $confdir/environments
EOF

  #Set the daemon to start automatically:
  sed -i 's/START=no/START=yes/g' /etc/default/puppet 
  sudo service puppet restart
  #Touch the puppet_installed.txt file to skip this block the next time around
  touch /home/vagrant/puppet_master_installed.txt
else
	echo "Skipping Puppet agent installation..."
fi