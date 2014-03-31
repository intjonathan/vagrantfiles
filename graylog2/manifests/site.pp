node 'puppet.local' {
  
#  class { 'puppetdb':
#    listen_address => '0.0.0.0'
#  }
#
#  include puppetdb::master::config

}

node 'graylogdb.local' {

}

node 'client1.local' {

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graylog2.local',
    port           => '10514',
  }

}

node 'client2.local' {

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graylog2.local',
    port           => '10514',
  }

}

node 'client3.local' {

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graylog2.local',
    port           => '10514',
  }

}