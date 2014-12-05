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

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

}

node 'heka2.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the role that sets up CollectD, sets it up to gather system and NTP metrics and
  #sends it to a Graphite (in this case, Heka) server:
  include role::collectd::collectd_system_and_ntp_metrics_and_write_graphite

}

node 'heka3.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

}

node 'collectd1.local' {

  #Install Apache so we test collectd's Apache metrics gathering.
  include profile::apache

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
  
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the role that sets up CollectD, sets it up to gather system and NTP metrics and
  #sends it to a Graphite (in this case, Heka) server:
  include role::collectd::collectd_system_and_ntp_metrics_and_write_graphite

}

node 'collectd2.local' {

  #Install Apache so we test collectd's Apache metrics gathering.
  include profile::apache

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
  
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Install Postfix locally so that Fail2Ban can send out emails
  class { '::postfix::server':
    inet_interfaces => 'localhost', #Only listen on localhost
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
  }

  #Include the role that sets up CollectD, sets it up to gather system and NTP metrics and
  #sends it to a Graphite (in this case, Heka) server:
  include role::collectd::collectd_system_and_ntp_metrics_and_write_graphite

}

node 'hekametrics.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the role that sets up CollectD, sets it up to gather system and NTP metrics and
  #sends it to a Graphite (in this case, Heka) server:
  include role::collectd::collectd_system_and_ntp_metrics_and_write_graphite

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

node 'hekalogging.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Install Apache so we test collectd's Apache metrics gathering.
  include profile::apache

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

  #Include the role that sets up CollectD, sets it up to gather system and NTP metrics and
  #sends it to a Graphite (in this case, Heka) server:
  include role::collectd::collectd_system_and_ntp_metrics_and_write_graphite

}

node 'hekamail.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include a profile that installs and configures Postfix:
  include profile::postfix

  #Include the profile that sets up my user account:
  include profile::users

}