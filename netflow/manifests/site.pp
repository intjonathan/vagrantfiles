#default node defition
node default {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

}

#Puppet master definition
node 'netflowmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
  class { 'rsyslog::server': }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#Ubuntu NetFlow node
node 'flow1.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'netflowmaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#Ubuntu NetFlow node
node 'flow2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'netflowmaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#CentOS NetFlow node
node 'flow3.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'netflowmaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#CentOS NetFlow node
node 'flow4.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'netflowmaster.local',
    port           => '514',
  }
  
    class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
}

#Ubuntu NetFlow node
node 'flow5.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'netflowmaster.local',
    port           => '514',
  }
  
    class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#CentOS NetFlow node
node 'flow6.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'netflowmaster.local',
    port           => '514',
  }
  
    class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
}