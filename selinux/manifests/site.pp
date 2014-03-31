#default node defition
node default {

}

#Puppet master node definition
node 'selinuxmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh
  
  class { 'rsyslog::server': }
 
}

#Ubuntu ElasticSearch node
node 'selinux1.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }
  
  package { 'smartmontools':
    ensure => installed,
  }
}

#Ubuntu ElasticSearch node
node 'selinux2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}

#Ubuntu ElasticSearch node
node 'selinux3.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}

#Ubuntu ElasticSearch node
node 'selinux4.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}