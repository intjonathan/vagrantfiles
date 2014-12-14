node 'consulmaster.local' {

  #Apache modules for PuppetBoard:
  include profile::apache::wsgi
  
  #Profiles for Puppetboard itself and its vhost:
  include profile::puppetboard
 
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the role that sets up PuppetDB, the Puppet master to work with PuppetDB and Puppetboard:
  include role::puppetdb::puppet_master_and_puppetdb_server_with_puppetboard

}

node 'consulserver1.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  class { 'consul':
    version => '0.4.0',
    config_hash => {
      #The data center this Consul agent is running in:
      'bind_addr'             => $ipaddress_eth1,
      'bootstrap_expect'      => 3,
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'config-dir'            => '/etc/consul.d/',
      'data_dir'              => '/opt/consul',
      'ui_dir'                => '/opt/consul/ui',
      'dc'                    => 'laptop1',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
      'server'                => true
    }
  }

}

node 'consulserver2.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  class { 'consul':
    version => '0.4.0',
    join_cluster => 'consulserver1.local',
    config_hash => {
      #The data center this Consul agent is running in:
      'bind_addr'             => $ipaddress_eth1,
      'bootstrap_expect'      => 3,
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'config-dir'            => '/etc/consul.d/',
      'data_dir'              => '/opt/consul',
      'dc'                    => 'laptop1',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
      'server'                => true
    }
  }

}

node 'consulserver3.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Install Apache so we can do a basic service check against HTTP port 80:
  include profile::apache

  class { 'consul':
    version => '0.4.0',
    join_cluster => 'consulserver1.local',
    config_hash => {
      #The data center this Consul agent is running in:
      'bind_addr'             => $ipaddress_eth1,
      'bootstrap_expect'      => 3,
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'config-dir'            => '/etc/consul.d/',
      'data_dir'              => '/opt/consul',
      'dc'                    => 'laptop1',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
      'server'                => true
    }
  }

}

node 'consulagent1.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client


  #Install Apache so we can do a basic service check against HTTP port 80:
  include profile::apache

  class { 'consul':
    version => '0.4.0',
    join_cluster => 'consulserver1.local',
    config_hash => {
      #The data center this Consul agent is running in:
      'bind_addr'             => $ipaddress_eth1,
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'config-dir'            => '/etc/consul.d/',
      'data_dir'              => '/opt/consul',
      'dc'                    => 'laptop1',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
    }
  }

}

node 'consulagent2.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Install Apache so we can do a basic service check against HTTP port 80:
  include profile::apache

  class { 'consul':
    version => '0.4.0',
    join_cluster => 'consulserver1.local',
    config_hash => {
      #The data center this Consul agent is running in:
      'bind_addr'             => $ipaddress_eth1,
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'config-dir'            => '/etc/consul.d/',
      'data_dir'              => '/opt/consul',
      'dc'                    => 'laptop1',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
    }
  }


}

node 'consulagent3.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Install Apache so we can do a basic service check against HTTP port 80:
  include profile::apache

  class { 'consul':
    version => '0.4.0',
    join_cluster => 'consulserver1.local',
    config_hash => {
      #The data center this Consul agent is running in:
      'bind_addr'             => $ipaddress_eth1,
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'config-dir'            => '/etc/consul.d/',
      'data_dir'              => '/opt/consul',
      'dc'                    => 'laptop1',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
    }
  }

}

node 'consullogging.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Install Apache so we can do a basic service check against HTTP port 80:
  include profile::apache

  #Install Java...
  include profile::java

  #Include Logstash
  include profile::logstash
  include profile::logstash::config

  #Include Elasticsearch
  include profile::elasticsearch

  #Include the profile that sets up a virtual host for Kibana3:
  include profile::kibana3::apache_virtualhost

  file {'/sites/apps/kibana3': 
    ensure => directory,
    owner => 'www-data',
    group => 'www-data',
    mode => '600',
  }

  class { 'consul':
    version => '0.4.0',
    join_cluster => 'consulserver1.local',
    config_hash => {
      #The data center this Consul agent is running in:
      'bind_addr'             => $ipaddress_eth1,
      'check_update_interval' => '2m',
      'client_addr'           => '0.0.0.0',
      'config-dir'            => '/etc/consul.d/',
      'data_dir'              => '/opt/consul',
      'dc'                    => 'laptop1',
      'enable_syslog'         => true,
      'log_level'             => 'INFO',
      'node_name'             => $fqdn,
    }
  }

}