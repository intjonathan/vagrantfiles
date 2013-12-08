#Node definitions

node 'logstash.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config 
 
}

node 'elasticsearch1.local', 'elasticsearch2.local' {
  
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


node 'kibanathree.local' {

}

node 'rsyslog1.local', 'rsyslog2.local' {

}