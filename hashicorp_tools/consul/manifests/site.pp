node 'consulmaster.local' {
  
    #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config

  #Apache modules for PuppetBoard:
  class { 'apache': 
    purge_configs => 'true'
  }
  
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }
  class { 'apache::mod::wsgi': }

  #Configure Puppetboard with this module: https://github.com/nibalizer/puppet-module-puppetboard
  class { 'puppetboard':
    manage_virtualenv => true,
  }

  #A virtualhost for PuppetBoard
  class { 'puppetboard::apache::vhost':
    vhost_name => "puppetboard.${fqdn}",
    port => 80,
  }

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }
 
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'consullogging.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

node 'consulserver1.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'consullogging.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we can do a basic service check against HTTP port 80:
  class { 'apache': 
    purge_configs => 'true'
  }

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

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'consullogging.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we can do a basic service check against HTTP port 80:
  class { 'apache': 
    purge_configs => 'true'
  }

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

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'consullogging.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we can do a basic service check against HTTP port 80:
  class { 'apache': 
    purge_configs => 'true'
  }

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

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'consullogging.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we can do a basic service check against HTTP port 80:
  class { 'apache': 
    purge_configs => 'true'
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

node 'consulagent2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'consullogging.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we can do a basic service check against HTTP port 80:
  class { 'apache': 
    purge_configs => 'true'
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

node 'consulagent3.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'consullogging.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we can do a basic service check against HTTP port 80:
  class { 'apache': 
    purge_configs => 'true'
  }

  #Apply this class so we can get the Nagios plugins packages installed:
  class { 'icinga::client': }
  
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

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'consullogging.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we can do a basic service check against HTTP port 80:
  class { 'apache': 
    purge_configs => 'true'
  }

  #Install Logstash:  
  class { 'logstash':
    java_install => true,
    java_package => 'openjdk-7-jre-headless',
    package_url => 'https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb',
    install_contrib => true,
    contrib_package_url => 'https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash-contrib_1.4.2-1-efd53ef_all.deb',
  }

  logstash::configfile { 'logstash_monolithic':
    source => 'puppet:///logstash/configs/logstash.conf',
    order   => 10
  }

  #Install Elasticsearch...
  class { 'elasticsearch':
    java_install => false,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb',
    config => { 'cluster.name'             => 'logstash',
                'network.host'             => $ipaddress_eth1,
                'index.number_of_replicas' => '1',
                'index.number_of_shards'   => '4',
    },
  }

  #...and some plugins:
  elasticsearch::instance { $fqdn:
    config => { 'node.name' => $fqdn }
  }

  elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head',
    instances  => $fqdn,
  }

  elasticsearch::plugin{'karmi/elasticsearch-paramedic':
    module_dir => 'paramedic',
    instances  => $fqdn,
  }

  elasticsearch::plugin{'lmenezes/elasticsearch-kopf':
    module_dir => 'kopf',
    instances  => $fqdn,
  }

  #A non-SSL virtual host for Kibana:
  ::apache::vhost { 'kibana.icinga2logging.local_non-ssl':
    port            => 80,
    docroot         => '/sites/apps/kibana3',
    servername      => "kibana.${fqdn}",
    access_log => true,
    access_log_syslog=> 'syslog:local1',
    error_log => true,
    error_log_syslog=> 'syslog:local1',
    custom_fragment => '
      #Disable multiviews since they can have unpredictable results
      <Directory "/sites/apps/kibana3">
        AllowOverride All
        Require all granted
        Options -Multiviews
      </Directory>
    ',
  }

  #Create a folder where the SSL certificate and key will live:
  file {'/etc/apache2/ssl': 
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '600',
  }

  #Create the directory (and its containing directories) for Kibana 3:
  file {'/sites/': 
    ensure => directory,
    owner => 'www-data',
    group => 'www-data',
    mode => '600',
  }

  file {'/sites/apps': 
    ensure => directory,
    owner => 'www-data',
    group => 'www-data',
    mode => '600',
  }

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