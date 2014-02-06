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
  
  include apache

}

#Jenkins worker
node 'worker1.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'jenkinsmaster.local',
      port           => '514',
  }

}

#Jenkins worker
node 'worker2.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'jenkinsmaster.local',
      port           => '514',
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

}

#Jenkins worker
node 'worker4.local' {

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'jenkinsmaster.local',
      port           => '514',
  }

}