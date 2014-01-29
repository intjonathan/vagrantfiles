#default node defition
node default {

  include ssh

}

#puppet master node definition
node 'icingamaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
  class { 'rsyslog::server': }
 
}

#Ubuntu Icinga server node

node 'ubuntuicinga.local' {

  class { 'postgresql::server': }

  postgresql::server::db { 'icinga':
    user     => 'icingaidoutils',
    password => postgresql_password('icingaidoutils', 'password'),
  }
  
  class { 'icinga::server':
    server_db_password => 'password'
  }

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'icingamaster.local',
      port           => '514',
  }

}

node 'centosicinga.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'icingamaster.local',
      port           => '514',
  }

}

node 'icingaclient1.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'icingamaster.local',
      port           => '514',
  }

}

node 'icingaclient2.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'icingamaster.local',
      port           => '514',
  }

}