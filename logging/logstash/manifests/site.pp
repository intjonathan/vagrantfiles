#Node definitions

node 'logstashmaster.local' {

  #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config

  #Apache modules for PuppetBoard:
  class { 'apache': }
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

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is: https://github.com/saz/puppet-rsyslog
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'udp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

}

node 'logstash.local' {

  #This module is: https://github.com/nickchappell/puppetlabs-denyhosts
  
 
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

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
#  file {'/etc/logstash.conf':
#    ensure => file,
#    mode => '0644',
#    owner => 'root',
#    group => 'root',
#    source => 'puppet:///logstash/configs/logstash.conf',  
#  }

#  file {'/etc/blah.conf':
#    ensure => file,
#    mode => '0644',
#    owner => 'root',
#    group => 'root',
#    source => 'puppet:///logstash/blah.conf',  
#  }
  
  class { 'logstash':
    manage_repo => true,
    repo_version => '1.4',
  }

  logstash::configfile { 'logstash_monolithic':
    source => 'puppet:///logstash/configs/logstash.conf',
    order   => 10
  }

}

node 'kibanathree.local' {
  
  #This module is: https://github.com/nickchappell/puppetlabs-denyhosts
  

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

  class{ '::apache':}
  
  #::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'rewrite': } #Install/enable the rewrite module

    #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is: https://github.com/saz/puppet-rsyslog
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'udp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #A non-SSL virtual host that just redirects to the SSL one below:
  ::apache::vhost { 'dashboard.kibanathree.local_non-ssl':
    port            => 80,
    docroot         => '/sites/apps/kibana3',
    servername      => "dashboard.${fqdn}",
    custom_fragment => '
      #Redirect to the HTTPS virtualhost
      RewriteEngine on
      ReWriteCond %{SERVER_PORT} !^443$
      RewriteRule ^/(.*) https://%{HTTP_HOST}/$1 [NC,R,L]',
  }

  #An SSL virtual host for Kibana 3
  ::apache::vhost { 'dashboard.kibanathree.local_ssl':
    port                 => 443,
    docroot              => '/sites/apps/kibana3',
    servername           => "dashboard.${fqdn}",
    ssl                  => true,
    ssl_cert             => '/etc/apache2/ssl/kibanathree.local.pem',
    ssl_key              => '/etc/apache2/ssl/kibanathree.local.key',
    ssl_protocol         => '+TLSv1 +TLSv1.1 +TLSv1.2 -SSLv2 -SSLv3',
    ssl_cipher           => 'ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA:!aNULL:!eNULL:!EXPORT:!DES:!3DES:!MD5:!PSK',
    ssl_honorcipherorder => 'On',
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

}

node 'elasticsearch1.local' {

  #This module is: https://github.com/nickchappell/puppetlabs-denyhosts
  
  
  class { 'elasticsearch':
    java_install => true,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb',
    config => {

      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '4'
      },
      'network' => {
        'host' => $ipaddress_eth1
      },
      'cluster' => {
        'name' => 'logstash',
      }
    }
  }

  elasticsearch::instance { $fqnd:
    config => { 'node.name' => $fqdn },
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

    #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is: https://github.com/saz/puppet-rsyslog
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'udp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }
  
}

node 'elasticsearch2.local', 'elasticsearch3.local', 'elasticsearch4.local' {
  
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

  #This module is: https://github.com/nickchappell/puppetlabs-denyhosts
  

    #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is: https://github.com/saz/puppet-rsyslog
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'udp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  class { 'elasticsearch':
    java_install => true,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb',
    config => {

      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '4'
      },
      'network' => {
        'host' => $ipaddress_eth1
      },
      'cluster' => {
        'name' => 'logstash',
      }
    }
  }

  elasticsearch::instance { $fqdn:
    config => { 'node.name' => $fqdn },
  }
  
}

node 'rsyslog1.local', 'rsyslog2.local' {

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

  #This module is: https://github.com/nickchappell/puppetlabs-denyhosts
  

    #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #This module is: https://github.com/saz/puppet-rsyslog
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'udp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

}