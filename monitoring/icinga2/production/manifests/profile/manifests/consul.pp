class profile::consul {

}


class profile::consul::agent {

}

class profile::consul::server {

  class { '::consul':
    version => '0.4.1',
    config_hash => {
      'bind_addr'             => $ipaddress_eth1,
      'bootstrap_expect'      => 1,
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'data_dir'              => '/opt/consul',
      'ui_dir'                => '/opt/consul/ui',
      'dc'                    => 'laptop23',
      'enable_syslog'         => true,
      'log_level'             => 'DEBUG',
      'node_name'             => $fqdn,
      'server'                => true
    }
  }

}

class profile::consul::client {

  class { '::consul':
    version => '0.4.1',
    config_hash => {
      'bind_addr'             => $ipaddress_eth1,
      'start_join'            => ['10.0.1.80'],
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'data_dir'              => '/opt/consul',
      'dc'                    => 'laptop23',
      'enable_syslog'         => true,
      'log_level'             => 'DEBUG',
      'node_name'             => $fqdn,
    }
  }

}