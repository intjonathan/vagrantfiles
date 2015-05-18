#! /bin/bash
echo Checking to see if the Puppet Labs RHEL/CentOS repo needs to be added...

if [ ! -f /home/vagrant/repos_added.txt ];
then
	sudo rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
	sudo yum check-update
	#Touch the repos_added file to skip this block the next time around
	touch /home/vagrant/repos_added.txt
else
	echo "Skipping repo addition..."
fi

if [ ! -f /home/vagrant/puppet_master_installed.txt ];
then
	sudo yum install puppet-server -y --nogpgcheck 
	sudo chkconfig --levels 2345 puppetmaster on
	sudo /etc/init.d/puppetmaster start
	sudo service iptables stop
  echo "cating sample puppet.conf into puppet.conf file..."
  sudo cat > /etc/puppet/puppet.conf <<"EOF"
[main]
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
environmentpath = $confdir/environments
EOF

sudo cat > /etc/puppet/hiera.yaml <<"EOF"
---
#Our hierarcy
:hierarchy:
  - node/%{fqdn}
  - operatingsystem/%{operatingsystem}
  - osfamily/%{osfamily}
  - common
#List the backends we want to use
:backends:
 - yaml
#For the YAML backend, specify the location of YAML data
:yaml:
  :datadir: '/etc/puppet/hieradata/yaml'
EOF

  sudo /etc/init.d/puppetmaster stop
  sudo puppet cert clean --all
  sudo puppet cert generate master --dns_alt_names=puppet,master,puppetmaster,puppet.local,master.local,puppetmaster.local
  sudo /etc/init.d/puppetmaster restart
  #Touch the puppet_installed.txt file to skip this block the next time around
  touch /home/vagrant/puppet_master_installed.txt
else
	echo "Skipping Puppet master installation..."
fi

if [ ! -f /home/vagrant/puppet_master_initial_run_complete.txt ];
then
  #Do an initial Puppet run to set up PuppetDB:
  puppet agent -t
  #Enable PuppetDB report storage...
  echo 'reports = store,puppetdb' >> /etc/puppet/puppet.conf
  #...and restart PuppetDB:
  service puppetmaster restart
  #Touch the puppet_master_initial_run_complete.txt file to skip this block the next time around
  touch /home/vagrant/puppet_master_initial_run_complete.txt
else
  echo "Skipping initial Puppet run..."
fi