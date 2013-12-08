#Node definitions

node 'logstash.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config 

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'logstash.local',
    port           => '5514',
  }

}

node 'elasticsearch1.local', 'elasticsearch2.local' {
  
 package {'openjdk-7-jdk':
    ensure => installed,
  }
  
  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.7.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '8'
      },
      'network' => {
        'host' => $ipaddress_eth1
      },
      'cluster' => {
        'name' => 'logstash',
      }
    }
  }
  
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'logstash.local',
    port           => '5514',
  }

}


node 'kibanathree.local' {
  
    class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'logstash.local',
    port           => '5514',
  }

}

node 'rsyslog1.local', 'rsyslog2.local' {

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'logstash.local',
    port           => '5514',
  }

}