#! /bin/bash
echo "Checking to see if the Puppet Labs apt repo needs to be added..."

if [ ! -f /home/vagrant/repos_added.txt ];
then    
	echo "Adding Puppet Labs apt repository..."
    sudo wget -N http://apt.puppetlabs.com/puppetlabs-release-raring.deb >/dev/null
    sudo dpkg -i puppetlabs-release-raring.deb >/dev/null
    echo "Updating apt..."
    sudo apt-get update >/dev/null
    #Touch the repos_added file to skip this block the next time around
	touch /home/vagrant/repos_added.txt

else
	echo "Skipping repo addition and package installation..."
fi

echo "Checking to see if the Puppet agent package needs to be installed..."

if [ ! -f /home/vagrant/puppet_agent_installed.txt ];
then
	echo "Installing the Puppet agent..."
	sudo apt-get -y install puppet >/dev/null
	echo "DONE installing the Puppet agent packages!"
		
	echo "Starting the Puppet agent daemon..."
	sudo /etc/init.d/puppet start >/dev/null
	echo "DONE starting the daemon!"
	
	echo "Stopping the UFW firewall..."
	sudo service ufw stop >/dev/null
	echo "DONE stopping ufw!"

    echo "cating sample puppet.conf into puppet.conf file..."

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
        reports=false
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

