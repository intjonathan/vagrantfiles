class profile::consul {

}


class profile::consul::agent {

}

class profile::consul::server {

  #Get the address of the host-only interface by looking up the right Facter fact for
  #it to get the right address. I need to do this because CentOS 7 has device names like
  #'enp0s8' as opposed to 'eth0' or 'eth1':
  if $operatingsystem == 'CentOS' and $operatingsystemmajrelease == '7' {
    class { '::consul':
      version => '0.5.0',
      config_hash => {
        'bind_addr'             => $::ipaddress_enp0s8,
        'bootstrap_expect'      => 1,
        'check_update_interval' => '2m',
        'retry_join'            => ['10.0.1.70'],
        'retry_interval'        => '10s',
        'client_addr'           => '0.0.0.0',
        'data_dir'              => '/opt/consul',
        'ui_dir'                => '/opt/consul/ui',
        'datacenter'            => 'bind',
        'enable_syslog'         => true,
        'log_level'             => 'INFO',
        'node_name'             => $fqdn,
        'server'                => true,
      }
    }
  } 
  #If it's not CentOS 7, just use ipaddress_eth1:
  else {
    class { '::consul':
      version => '0.5.0',
      config_hash => {
        'bind_addr'             => $::ipaddress_eth1,
        'bootstrap_expect'      => 1,
        'check_update_interval' => '2m',
        'retry_join'            => ['10.0.1.70'],
        'retry_interval'        => '10s',
        'client_addr'           => '0.0.0.0',
        'data_dir'              => '/opt/consul',
        'ui_dir'                => '/opt/consul/ui',
        'datacenter'            => 'bind',
        'enable_syslog'         => true,
        'log_level'             => 'INFO',
        'node_name'             => $fqdn,
        'server'                => true,
      }
    } 
  }

}

class profile::consul::client {

  #Get the address of the host-only interface by looking up the right Facter fact for
  #it to get the right address. I need to do this because CentOS 7 has device names like
  #'enp0s8' as opposed to 'eth0' or 'eth1':
  if $operatingsystem == 'CentOS' and $operatingsystemmajrelease == '7' {
    class { '::consul':
      version => '0.5.0',
      config_hash => {
        #Get the address of the host-only interface by looking up the right Facter fact for
        #it to get the right address. I need to do this because CentOS 7 has device names like
        #'enp0s8' as opposed to 'eth0' or 'eth1'
        'bind_addr'             => $::ipaddress_enp0s8,
        'start_join'            => ['10.0.1.70'],
        'check_update_interval' => '2m',
        'retry_join'            => ['10.0.1.70'],
        'retry_interval'        => '10s',
        'client_addr'           => '0.0.0.0',
        'data_dir'              => '/opt/consul',
        'datacenter'            => 'bind',
        'enable_syslog'         => true,
        'log_level'             => 'INFO',
        'node_name'             => $fqdn,
      }
    }
  } 
  #If it's not CentOS 7, just use ipaddress_eth1:
  else {
    class { '::consul':
      version => '0.5.0',
      config_hash => {
        #Get the address of the host-only interface by looking up the right Facter fact for
        #it to get the right address. I need to do this because CentOS 7 has device names like
        #'enp0s8' as opposed to 'eth0' or 'eth1'
        'bind_addr'             => $::ipaddress_eth1,
        'start_join'            => ['10.0.1.70'],
        'check_update_interval' => '2m',
        'retry_join'            => ['10.0.1.70'],
        'retry_interval'        => '10s',
        'client_addr'           => '0.0.0.0',
        'data_dir'              => '/opt/consul',
        'datacenter'            => 'bind',
        'enable_syslog'         => true,
        'log_level'             => 'INFO',
        'node_name'             => $fqdn,
      }
    }
  }

}