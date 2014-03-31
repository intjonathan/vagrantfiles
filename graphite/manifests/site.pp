#default node defition
node default {

  include ssh

}

#Puppet master definition
node 'graphitemaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config

  #Apache for PuppetBoard:
  class { 'apache': }
  class { 'apache::mod::wsgi': }

  #Configure Puppetboard
  class { 'puppetboard':
    manage_virtualenv => true,
  }

  #A virtualhost for PuppetBoard
  class { 'puppetboard::apache::vhost':
    vhost_name => "puppetboard.${fqdn}",
    port => 80,
  }
  
  class { 'rsyslog::server': }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#Ubuntu Graphite server
node 'graphite1.local' {

  #include apache

  #Install Postgres:
  class { 'postgresql::server': }

  #Create a Postgres DB for Graphite
  postgresql::server::db { 'graphite_data':
    user     => 'graphite',
    password => postgresql_password('graphite', 'password'),
  }
  
  #Install MySQL:
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }
  
  #Create a MySQL DB for Graphite  
  mysql::db { 'graphite_data':
    user     => 'graphite',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }
  
}

#CentOS Graphite server
node 'graphite2.local' {

}

#Ubuntu Graphite node
node 'node1.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  include collectd
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'graphitemaster.local',
  }
  

}

#Ubuntu Graphite node
node 'node2.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  include collectd
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'graphitemaster.local',
  }

}

#CentOS Graphite node
node 'node3.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#CentOS Graphite node
node 'node4.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }
  
    class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
}

#Ubuntu Graphite node
node 'node5.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }
  
    class { '::ntp':
    servers  => [ '0.ubuntu.pool.node.org', '1.ubuntu.pool.node.org', '2.ubuntu.pool.node.org', '3.ubuntu.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  include collectd
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'graphitemaster.local',
  }

}

#CentOS Graphite node
node 'node6.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }
  
    class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
}