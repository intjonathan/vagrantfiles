#default node defition
node default {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

}

#puppet master node definition
node 'jenkinsmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::server': }

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#Ubuntu Jenkins server
node 'ubuntujenkins.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'jenkinsmaster.local',
      port           => '514',
  }

	class { 'oracle_java':
		type      => 'jdk',
		arc       => 'x64',
		version   => '7u51',
		os        => 'linux',
	}

  class { '::jenkins::master':
    version => '1.15',
  }

	class { '::jenkins':
	  install_java => false,
	  configure_firewall => false,
	  config_hash => {  
      'JENKINS_LISTEN_ADDRESS' => {'value' => '10.0.1.49s',} 
    },
	}

	::jenkins::plugin {
    "git" : ;
  }
  
  ::jenkins::plugin {
    "ant" : ;
  }

  ::jenkins::plugin {
    "gradle" : ;
  }
  
  #Install Postfix locally so that Jenkins can send out emails
  class { '::postfix::server':
    inet_interfaces => 'localhost', #Only listen on localhost
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'netx.net',
  }

}


#CentOS Jenkins server
node 'centosjenkins.local' {

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'jenkinsmaster.local',
      port           => '514',
  }

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh
  
  class{ 'apache':
    purge_configs => false, #Leave existing manually created Apache configurations in place
  }
  
  apache::mod { 'ssl': } #Install/enable the SSL module
  
  #VirtualHost for proxying to a Jenkins install that's running locally
  apache::vhost { "jenkins.${fqdn}":
    port            => 80,
    docroot         => '/var/www',
    servername      => "jenkins.${fqdn}",
    custom_fragment => '
    #blah comments for my apache virtualhost
    <Proxy *>
      Order deny,allow
      Allow from all
    </Proxy>
 
    ProxyRequests Off
    ProxyPreserveHost On
    #Make the default location (with no /whatever) go to Jenkins:
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
    ',
  }

	class { 'oracle_java':
		type      => 'jdk',
		arc       => 'x64',
		version   => '7u51',
		os        => 'linux',
	}


  include jenkins::master
	
	class { 'jenkins':
	  install_java => false,
	  configure_firewall => false,
	  config_hash => {  
      'JENKINS_LISTEN_ADDRESS' => {'value' => '10.0.1.49',} 
    },
	}

	jenkins::plugin {
    "git" : ;
  }
  
  jenkins::plugin {
    "ant" : ;
  }

  jenkins::plugin {
    "gradle" : ;
  }

}

#Jenkins worker
node 'worker1.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'jenkinsmaster.local',
    port           => '514',
  }

	class { 'oracle_java':
		type      => 'jdk',
		arc       => 'x64',
		version   => '7u51',
		os        => 'linux',
	}

  class { '::jenkins::slave':
    masterurl => 'http://ubuntujenkins.local:8080',
    executors => 8,
    install_java => false,
    version => '1.15',
  }

}

#Jenkins worker
node 'worker2.local' {
  
  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'jenkinsmaster.local',
    port           => '514',
  }

	class { 'oracle_java':
		type      => 'jdk',
		arc       => 'x64',
		version   => '7u51',
		os        => 'linux',
	}

  class { '::jenkins::slave':
    masterurl => 'http://ubuntujenkins.local:8080',
    executors => 8,
    install_java => false,
    version => '1.15',
  }

}

#Jenkins worker
node 'worker3.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'jenkinsmaster.local',
    port           => '514',
  }

	class { 'oracle_java':
		type      => 'jdk',
		arc       => 'x64',
		version   => '7u51',
		os        => 'linux',
	}

  class { '::jenkins::slave':
    masterurl => 'http://ubuntujenkins.local:8080',
    executors => 8,
    install_java => false,
    version => '1.15',
  }

}

#Jenkins worker
node 'worker4.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'jenkinsmaster.local',
    port           => '514',
  }

	class { 'oracle_java':
		type      => 'jdk',
		arc       => 'x64',
		version   => '7u51',
		os        => 'linux',
	}

  class { '::jenkins::slave':
    masterurl => 'http://ubuntujenkins.local:8080',
    executors => 8,
    install_java => false,
    version => '1.15',
  }

}