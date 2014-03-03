#default node defition
node default {

  include ssh

}

#puppet master node definition
node 'jenkinsmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
  class { 'rsyslog::server': }
 
}

#Ubuntu Jenkins server
node 'ubuntujenkins.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'jenkinsmaster.local',
      port           => '514',
  }
  
  include apache
}


#CentOS Jenkins server
node 'centosjenkins.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'jenkinsmaster.local',
      port           => '514',
  }

  include ssh
  
  class{ 'apache':
    purge_configs => false, #Leave existing manually created Apache configurations in place
  }
  
  apache::mod { 'ssl': } #Install/enable the SSL module
  
  #VirtualHost for proxying to a Jenkins install that's running locally
  apache::vhost { 'jenkins.centosjenkins.local':
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
      'JENKINS_LISTEN_ADDRESS' => {'value' => '127.0.0.1',} 
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

  include ssh

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

  class { 'jenkins::slave':
    masterurl => 'http://jenkins.centosjenkins.local',
    executors => 5,
    install_java => false,
  }

}

#Jenkins worker
node 'worker2.local' {

  include ssh

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

  class { 'jenkins::slave':
    masterurl => 'http://jenkins.centosjenkins.local',
    executors => 5,
    install_java => false,
  }

}

#Jenkins worker
node 'worker3.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'jenkinsmaster.local',
      port           => '514',
  }

  include ssh
  
	class { 'oracle_java':
		type      => 'jdk',
		arc       => 'x64',
		version   => '7u51',
		os        => 'linux',
	}

  class { 'jenkins::slave':
    masterurl => 'http://jenkins.centosjenkins.local',
    executors => 5,
    install_java => false,
  }

}

#Jenkins worker
node 'worker4.local' {

  include ssh

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

  class { 'jenkins::slave':
    masterurl => 'http://jenkins.centosjenkins.local',
    executors => 5,
    install_java => false,
  }

}