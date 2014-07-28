#! /bin/bash
echo "Checking to see if the Puppet Labs RHEL/CentOS repo needs to be added..."
if [ ! -f /home/vagrant/repos_added.txt ];
then    
	sudo rpm -Uvhi http://yum.puppetlabs.com/puppetlabs-release-el-7.noarch.rpm
	sudo yum check-update
	#Touch the repos_added file to skip this block the next time around
	touch /home/vagrant/repos_added.txt
else
	echo "Skipping repo addition..."
fi

echo "Checking to see if the Puppet agent package needs to be installed..."
if [ ! -f /home/vagrant/puppet_agent_installed.txt ];
then
	sudo yum install --disablerepo=epel puppet -y
	sudo systemctl enable puppet.service
	sudo systemctl start puppet.service
	sudo service iptables stop
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
	#Touch the puppet_installed.txt file to skip this block the next time around
	touch /home/vagrant/puppet_agent_installed.txt
else
	echo "Skipping Puppet agent package installation..."
fi