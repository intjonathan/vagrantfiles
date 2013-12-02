node 'master.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
 include puppetdb::master::config  
}


node 'agent1.local', 'agent2.local', 'agent3.local', 'agent4.local'{

  class {'snmp_client':
    agent_ip_addr_range    => '10.0.1.0/24',
    agent_listen_interface => $ipaddress_eth1,
    vacm_views => ['rouser nick priv'],
  }  
  
  snmp_client::snmpv3user {'nick':
    auth_type => 'SHA',
    auth_secret => 'password',
    priv_type => 'AES',
    priv_secret => 'secret00',
  }

}

node 'elasticsearch1.local', 'elasticsearch2.local', 'elasticsearch3.local', 'elasticsearch4.local' {

  package {'openjdk-7-jre-headless':
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
        'name' => 'logdatabase',
      }
    }
  }
}

node 'logstash.local' {

  package {'openjdk-7-jre-headless':
    ensure => installed,
  }
  
}