#puppet master node definition
node 'hekamaster.local' {

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

  #Include the role that sets up CollectD, sets it up to gather system and NTP metrics and
  #sends it to a Graphite (in this case, Heka) server:
  include role::collectd::collectd_system_and_ntp_metrics_and_write_graphite
  
}

node 'heka1.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'hekalogging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

node 'heka2.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'hekalogging.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Collectd so we can get metrics from this machine into heka/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Gather NTP stats:
  class { 'collectd::plugin::ntpd':
    host           => 'localhost',
    port           => 123,
    reverselookups => false,
    includeunitid  => false,
  }
  
  #Write the collectd status to the heka VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'heka1.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

}

node 'collectd1.local' {

  #Install Apache so we test collectd's Apache metrics gathering.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  class { 'apache': 
    purge_configs => 'true'
  }
  
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }

  #Install MySQL to test collectd's MySQL metrics gathering.
  #This module is the Puppet Labs MySQL module: https://github.com/puppetlabs/puppetlabs-mysql
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    users => {
      #Create a collectd DB user:
      'collectd@localhost' => {
          ensure                   => 'present',
          max_connections_per_hour => '0',
          max_queries_per_hour     => '0',
          max_updates_per_hour     => '0',
          max_user_connections     => '0',
          password_hash            => mysql_password('password'),
        }
    },
    grants => {
      #Let the collectd DB user read
      'collectd@localhost/*.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['USAGE'],
        table      => '*.*',
        user       => 'collectd@localhost',
      },
    }
  }

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'hekalogging.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Collectd so we can get metrics from this machine into heka/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Gather NTP stats:
  class { 'collectd::plugin::ntpd':
    host           => 'localhost',
    port           => 123,
    reverselookups => false,
    includeunitid  => false,
  }
  
  #Write the collectd status to the heka VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'heka1.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

}

node 'collectd2.local' {

  #Install Apache so we test collectd's Apache metrics gathering.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  class { 'apache': 
    purge_configs => 'true'
  }
  
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }

  #Install MySQL to test collectd's MySQL metrics gathering.
  #This module is the Puppet Labs MySQL module: https://github.com/puppetlabs/puppetlabs-mysql
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    users => {
      #Create a collectd DB user:
      'collectd@localhost' => {
          ensure                   => 'present',
          max_connections_per_hour => '0',
          max_queries_per_hour     => '0',
          max_updates_per_hour     => '0',
          max_user_connections     => '0',
          password_hash            => mysql_password('password'),
        }
    },
    grants => {
      #Let the collectd DB user read
      'collectd@localhost/*.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['USAGE'],
        table      => '*.*',
        user       => 'collectd@localhost',
      },
    }
  }

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'hekalogging.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postfix locally so that Fail2Ban can send out emails
  class { '::postfix::server':
    inet_interfaces => 'localhost', #Only listen on localhost
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
  }


  #Install Collectd so we can get metrics from this machine into heka/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Gather NTP stats:
  class { 'collectd::plugin::ntpd':
    host           => 'localhost',
    port           => 123,
    reverselookups => false,
    includeunitid  => false,
  }
  
  #Write the collectd status to the heka VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'heka1.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

}

node 'influxdb1.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'hekalogging.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Collectd so we can get metrics from this machine into heka/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Gather NTP stats:
  class { 'collectd::plugin::ntpd':
    host           => 'localhost',
    port           => 123,
    reverselookups => false,
    includeunitid  => false,
  }
  
  #Write the collectd status to the heka VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'heka1.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

  #Install Java so we can run ElasticSearch:
  package {'openjdk-7-jdk':
    ensure => installed,
  } ->

  class { 'elasticsearch':
    java_install => false,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.2.2.deb',
    config => { 'cluster.name'             => 'grafana',
                'network.host'             => $ipaddress_eth1,
                'index.number_of_replicas' => '1',
                'index.number_of_shards'   => '4',
    },
  }

  elasticsearch::instance { $fqdn:
    config => { 'node.name' => $fqdn }
  }


}

node 'grafana1.local' {

  #Apache module classes for Grafana:
  class { 'apache': 
    purge_configs => 'true'
  }

  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }
  
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

  file {'/sites/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  file {'/sites/apps/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'hekalogging.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Collectd so we can get metrics from this machine into heka/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Gather NTP stats:
  class { 'collectd::plugin::ntpd':
    host           => 'localhost',
    port           => 123,
    reverselookups => false,
    includeunitid  => false,
  }
  
  #Write the collectd status to the heka VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'heka1.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

}

node 'hekalogging.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'hekalogging.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }


  #Apache module classes for Grafana:
  class { 'apache': 
    purge_configs => 'true'
  }

  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }

  #Install Java...
  package { 'openjdk-7-jre-headless':
    ensure => installed,
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

  file {'/sites/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  file {'/sites/apps/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  #A non-SSL virtual host for Kibana:
  ::apache::vhost { 'kibana.hekalogging.local_non-ssl':
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

  #Install Collectd so we can get metrics from this machine into heka/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Gather NTP stats:
  class { 'collectd::plugin::ntpd':
    host           => 'localhost',
    port           => 123,
    reverselookups => false,
    includeunitid  => false,
  }
  
  #Write the collectd status to the heka VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'heka1.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

}

node 'hekaelasticsearch.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'hekalogging.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }


  #Apache module classes for Grafana:
  class { 'apache': 
    purge_configs => 'true'
  }

  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }

  #Install Java...
  package { 'openjdk-7-jre-headless':
    ensure => installed,
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

  file {'/sites/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  file {'/sites/apps/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  #A non-SSL virtual host for Kibana:
  ::apache::vhost { 'kibana.hekalogging.local_non-ssl':
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

  #Install Collectd so we can get metrics from this machine into heka/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  collectd::plugin { 'processes': }
  collectd::plugin { 'vmem': }
  class { 'collectd::plugin::load':}
  
  #Gather NTP stats:
  class { 'collectd::plugin::ntpd':
    host           => 'localhost',
    port           => 123,
    reverselookups => false,
    includeunitid  => false,
  }
  
  #Write the collectd status to the heka VM in the Graphite format:
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'heka1.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

}

node 'hekamail.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'hekalogging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  #Create a user account so we can test receiving mail:
  user { 'nick':
    ensure => present,
    home => '/home/nick',
    groups => ['sudo', 'admin'],
    #This is 'password', in salted SHA-512 form:
    password => '$6$IPYwCTfWyO$bIVTSw4ai/BGtZpfI4HtC8XE7bmb8b3kdZ6gRz4DF4hm7WmD35azXoFxN90TRrSYQdKo011YnBl7p3UXR2osQ1',
    shell => '/bin/bash',
  }

  file { '/home/nick' :
    ensure => directory,
    owner => 'nick',
    group => 'nick',
    mode =>  '755',
  }

}