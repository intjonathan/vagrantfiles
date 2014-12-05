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

  #Include a profile that installs and configures Postfix:
  include profile::postfix

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
  
  #Install Java via the Java profile
  include profile::java ->

  #Include Elasticsearch
  include profile::elasticsearch

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
  include profile::java

  #Include Logstash
  include profile::logstash
  include profile::logstash::config

  #Include Elasticsearch
  include profile::elasticsearch

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