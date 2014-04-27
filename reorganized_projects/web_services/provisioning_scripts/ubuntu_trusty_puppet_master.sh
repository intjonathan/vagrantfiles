#! /bin/bash
echo "Checking to see if the Puppet Labs apt repo needs to be added..."

if [ ! -f /home/vagrant/repos_added.txt ];
then    
	echo "Adding Puppet Labs apt repository..."
    sudo wget -N http://apt.puppetlabs.com/puppetlabs-release-trusty.deb >/dev/null
    sudo dpkg -i puppetlabs-release-trusty.deb >/dev/null
    echo "Updating apt..."
    sudo apt-get update >/dev/null
    #Touch the repos_added file to skip this block the next time around
	touch /home/vagrant/repos_added.txt

else
	echo "Skipping repo addition and package installation..."
fi

if [ ! -f /home/vagrant/puppet_master_installed.txt ];
then
	echo "Installing the Puppet master..."
	sudo apt-get -y install puppetmaster >/dev/null
	echo "DONE installing the Puppet master packages!"
	
	echo "Starting the Puppet master daemon..."
	sudo /etc/init.d/puppetmaster start >/dev/null
	echo "DONE starting the daemon!"
	
	echo "Stopping the UFW firewall..."
	sudo service ufw stop >/dev/null
	echo "DONE stopping ufw!"

	echo "Administratively enabling the agent..."
	sudo puppet agent --enable >/dev/null
	echo "DONE enabling the agent!"

    echo "concatenating sample puppet.conf into puppet.conf file..."
    sudo cat > /etc/puppet/puppet.conf <<"EOF"
    [main]
    logdir=/var/log/puppet
    vardir=/var/lib/puppet
    ssldir=/var/lib/puppet/ssl
    rundir=/var/run/puppet
    factpath=$vardir/lib/facter
    templatedir=$confdir/templates

    [master]
    # These are needed when the puppetmaster is run by passenger
    # and can safely be removed if webrick is used.
    ssl_client_header = SSL_CLIENT_S_DN 
    ssl_client_verify_header = SSL_CLIENT_VERIFY
    dns_alt_names = puppet,master,puppetmaster,puppet.local,master.local,puppetmaster.local
    reports = store,puppetdb
EOF
    
    echo "Regenerating Puppet master certificate with the 'puppet' DNS altname..."
    sudo /etc/init.d/puppetmaster stop >/dev/null
    sudo puppet cert clean --all >/dev/null
    sudo puppet cert generate master --dns_alt_names=puppet,master,puppetmaster,puppet.local,master.local,puppetmaster.local >/dev/null
    sudo /etc/init.d/puppetmaster restart >/dev/null
    echo "DONE regenerating the master certificate!"
    
    #Touch the puppet_installed.txt file to skip this block the next time around
	touch /home/vagrant/puppet_master_installed.txt
else
	echo "Skipping Puppet master installation..."
fi
