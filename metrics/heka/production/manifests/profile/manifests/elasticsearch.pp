class profile::elasticsearch {

    class { 'elasticsearch':
    java_install => false,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.1.deb',
    config => { 'cluster.name'             => 'heka',
                'network.host'             => $ipaddress_eth1,
                'index.number_of_replicas' => '1',
                'index.number_of_shards'   => '4',
    },
  }

  elasticsearch::instance { $fqdn:
    config => { 'node.name' => $fqdn }
  }

}