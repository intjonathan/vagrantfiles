class profile::cassandra {

  #JNA is Java Native Access; it prevents Linux from swapping out the JVM:
  # http://docs.datastax.com/en/cassandra/2.0/cassandra/install/installJnaRHEL.html
  package { 'jna':
    ensure => installed,
  }

}

class profile::cassandra::logging {

  rsyslog::imfile { 'cassandra':
    file_name => '/var/log/cassandra/cassandra.log',
    file_tag => 'cassandra',
    file_facility => 'local7',
    file_severity => 'info',
  }

  rsyslog::imfile { 'cassandra-system':
    file_name => '/var/log/cassandra/system.log',
    file_tag => 'cassandra-system',
    file_facility => 'local7',
    file_severity => 'info',
  }

}

class profile::cassandra::seed {

  #Include the base Cassandra profile so we can get JNA installed:
  include profile::cassandra
  
  #Include the logging profile so we can get logs into rsyslog:
  include profile::cassandra::logging

  class { '::cassandra':
    cluster_name      => 'zookeeper1',
    package_name      => 'dsc20',
    seeds             => [hiera('cassandra_seed_node')],
    version           => '2.0.14-1',
    listen_address    => $::ipaddress_enp0s8,
    rpc_address       => $::ipaddress_enp0s8,
    rpc_min_threads   => 16,
    rpc_max_threads   => 2048,
  }

}

class profile::cassandra::node {

  #Include the base Cassandra profile so we can get JNA installed:
  include profile::cassandra
  
  #Include the logging profile so we can get logs into rsyslog:
  include profile::cassandra::logging

  class { '::cassandra':
    cluster_name      => 'zookeeper1',
    package_name      => 'dsc20',
    seeds             => [hiera('cassandra_seed_node')],
    version           => '2.0.14-1',
    listen_address    => $::ipaddress_enp0s8,
    rpc_address       => $::ipaddress_enp0s8,
    rpc_min_threads   => 16,
    rpc_max_threads   => 2048,
  }

}
