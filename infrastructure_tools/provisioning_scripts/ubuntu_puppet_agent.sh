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

if [ ! -f /home/vagrant/puppet_agent_installed.txt ];
then
	sudo apt-get -y install puppet
	sudo service ufw stop

  sudo cat > /etc/puppet/puppet.conf <<"EOF"
[main]
# The Puppet log directory.
# The default value is '$vardir/log'.
logdir = /var/log/puppet

# Where Puppet PID files are kept.
# The default value is '$vardir/run'.
rundir = /var/run/puppet

# Where SSL certificates are kept.
# The default value is '$confdir/ssl'.
ssldir = /var/lib/puppet/ssl/

server=puppet
reports=true
pluginsync=true

[agent]
# The file in which puppetd stores a list of the classes
# associated with the retrieved configuratiion.  Can be loaded in
# the separate ``puppet`` executable using the ``--loadclasses``
# option.
# The default value is '$confdir/classes.txt'.
classfile = $vardir/classes.txt

# Where puppetd caches the local configuration.  An
# extension indicating the cache format is added automatically.
# The default value is '$confdir/localconfig'.
localconfig = $vardir/localconfig
EOF

  #Set the daemon to start automatically:
  sed -i 's/START=no/START=yes/g' /etc/default/puppet 
  sudo service puppet restart
  #Touch the puppet_installed.txt file to skip this block the next time around
  touch /home/vagrant/puppet_agent_installed.txt
else
	echo "Skipping Puppet agent installation..."
fi