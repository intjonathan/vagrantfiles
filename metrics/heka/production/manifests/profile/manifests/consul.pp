class profile::consul {

}


class profile::consul::agent {

}

class profile::consul::server {

  class { '::consul':
    version => '0.5.0',
    config_hash => {
      'bind_addr'             => $ipaddress_eth1,
      'bootstrap_expect'      => 3,
      'check_update_interval' => '2m',
      'retry_join'            => ['10.0.1.110'],
      'retry_interval'        => '10s',
      'client_addr'           => '0.0.0.0',
      'data_dir'              => '/opt/consul',
      'ui_dir'                => '/opt/consul/ui',
      'dc'                    => 'logstash',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
      'server'                => true
    }
  }

}

class profile::consul::client {

  class { '::consul':
    version => '0.5.0',
    config_hash => {
      'bind_addr'             => $ipaddress_eth1,
      'start_join'            => ['10.0.1.110'],
      'check_update_interval' => '2m',
      'retry_join'            => ['10.0.1.110'],
      'retry_interval'        => '10s',
      'client_addr'           => '0.0.0.0',
      'data_dir'              => '/opt/consul',
      'dc'                    => 'logstash',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
    }
  }

}