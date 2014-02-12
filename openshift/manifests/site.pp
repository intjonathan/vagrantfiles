#default node defition
node default {

  include ssh

}


#Puppet master node definition
node 'openshiftmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
  class { 'rsyslog::server': }
 
}

#CentOS OpenShift broker node
node 'broker.local' {

  include ssh

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'openshiftmaster.local',
      port           => '514',
  }
  
  class { '::ntp':
    servers => [ '0.pool.ntp.org', '1.pool.ntp.org', '2.pool.ntp.org', '3.pool.ntp.org' ],
    restrict => ['127.0.0.1'],
  }

}

#CentOS OpenShift ActiveMQ server
node 'activemq.local' {

  include ssh

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'openshiftmaster.local',
      port           => '514',
  }

}

#CentOS OpenShift MongoDB server
node 'mongodb.local' {

  include ssh

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'openshiftmaster.local',
      port           => '514',
  }

}

#CentOS OpenShift node
node 'node1.local' {

  include ssh

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'openshiftmaster.local',
      port           => '514',
  }

}

#CentOS OpenShift node
node 'node2.local' {

  include ssh

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'openshiftmaster.local',
      port           => '514',
  }

}

#CentOS OpenShift node
node 'node3.local' {


  include ssh

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'openshiftmaster.local',
      port           => '514',
  }

}

#CentOS OpenShift node
node 'node4.local' {

  include ssh

  class { 'rsyslog::client':
      log_remote     => true,
      remote_type    => 'tcp',
      log_local      => true,
      log_auth_local => true,
      custom_config  => undef,
      server         => 'openshiftmaster.local',
      port           => '514',
  }

}