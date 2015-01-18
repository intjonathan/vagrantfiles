class profile::elasticsearch {

    class { '::elasticsearch':
    java_install => false,
    #hieravaluereplace
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.1.deb',
    config => { 'cluster.name'             => 'logstash',
                'network.host'             => $ipaddress_eth1,
                'index.number_of_replicas' => '1',
                'index.number_of_shards'   => '4',
                'http.cors.enabled'        => 'true',
                'http.cors.allow-origin'   => "http://kibana.${fqdn}"
    },
  }

  ::elasticsearch::instance { $fqdn:
    config => { 'node.name' => $fqdn }
  }

  #...and some plugins:
  ::elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head',
    instances  => $fqdn,
  }

  ::elasticsearch::plugin{'karmi/elasticsearch-paramedic':
    module_dir => 'paramedic',
    instances  => $fqdn,
  }

  ::elasticsearch::plugin{'lmenezes/elasticsearch-kopf':
    module_dir => 'kopf',
    instances  => $fqdn,
  }

}