#puppet master node definition
node 'dnspuppetmaster.local' {

  #Apache modules for PuppetBoard:
  include profile::apache::wsgi
  
  #Profiles for Puppetboard itself and its vhost:
  include profile::puppetboard
  
  #Profile for setting up puppetexplorer:
  include profile::puppetexplorer
 
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the role that sets up PuppetDB, the Puppet master to work with PuppetDB and Puppetboard:
  include role::puppetdb::puppet_master_and_puppetdb_server_with_puppetboard
  
  #Make this machine a Consul server for all of the Icinga 2 client and server VMs
  include profile::consul::server
}

node 'dnsmaster1.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client
 
  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

  ###############################
  # Icinga 2 host export stuff
  ###############################

  include profile::icinga2::hostexport

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################

  #BIND module is from: https://github.com/thias/puppet-bind
  include bind
  bind::server::conf { '/etc/bind/named.conf':
    acls => {
      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ],
      'local'   => [ '127.0.0.1' ],
      '10net'   => [ '10.0.0.0/24', '10.0.1.0/24', '10.1.1.0/24', '10.1.0.0/24'],
    },
    directory => '/etc/bind/',
    listen_on_addr    => [ '127.0.0.1' ],
    listen_on_v6_addr => [ '::1' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localhost', 'local' ],
    recursion         => 'no',
    allow_recursion   => [ 'localhost', 'local', '10net'],
    #Include some other zone files for localhost and loopback zones:
    includes => ['/etc/bind/named.conf.local', '/etc/bind/named.conf.default-zones'],
    zones => {
      #root hints zone
      '.' => [
        'type hint',
        'file "/etc/bind/db.root"',
      ], 
      'zone1.local' => [
      'type master',
      'file "zone1.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone2.local' => [
      'type master',
      'file "zone2.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone3.local' => [
      'type master',
      'file "zone3.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone4.local' => [
      'type master',
      'file "zone4.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone5.local' => [
      'type master',
      'file "zone5.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    }
  }

}

node 'dnsmaster2.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client
 
  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

  ###############################
  # Icinga 2 host export stuff
  ###############################

  include profile::icinga2::hostexport

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################

  #BIND module is from: https://github.com/thias/puppet-bind
  include bind
  bind::server::conf { '/etc/bind/named.conf':
    acls => {
      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ],
      'local'   => [ '127.0.0.1' ],
      '10net'   => [ '10.0.0.0/24', '10.0.1.0/24', '10.1.1.0/24', '10.1.0.0/24'],
    },
    directory => '/etc/bind/',
    listen_on_addr    => [ '127.0.0.1' ],
    listen_on_v6_addr => [ '::1' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localhost', 'local' ],
    recursion         => 'no',
    allow_recursion   => [ 'localhost', 'local', '10net'],
    #Include some other zone files for localhost and loopback zones:
    includes => ['/etc/bind/named.conf.local', '/etc/bind/named.conf.default-zones'],
    zones => {
      #root hints zone
      '.' => [
        'type hint',
        'file "/etc/bind/db.root"',
      ], 
      'zone1.local' => [
      'type master',
      'file "zone1.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone2.local' => [
      'type master',
      'file "zone2.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone3.local' => [
      'type master',
      'file "zone3.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone4.local' => [
      'type master',
      'file "zone4.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone5.local' => [
      'type master',
      'file "zone5.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    }
  }

}

node 'dnsslave1.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client
 
  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

  ###############################
  # Icinga 2 host export stuff
  ###############################

  include profile::icinga2::hostexport

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################

  #BIND module is from: https://github.com/thias/puppet-bind
  #Just install the BIND package:
  include bind::package

}

node 'dnsslave2.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client
 
  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

  ###############################
  # Icinga 2 host export stuff
  ###############################

  include profile::icinga2::hostexport

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  include profile::icinga2::nrpe::objects

  ###############################
  # BIND installation/setup
  ###############################

  #BIND module is from: https://github.com/thias/puppet-bind
  #Just install the BIND package:
  include bind::package

}

node 'dnsclient1.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

  ###############################
  # Icinga 2 host export stuff
  ###############################

  include profile::icinga2::hostexport

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  include profile::icinga2::nrpe::objects

}

node 'dnsclient2.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

  ###############################
  # Icinga 2 host export stuff
  ###############################

  include profile::icinga2::hostexport

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  include profile::icinga2::nrpe::objects

}

node 'dnsmonitoring.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # Postfix installation/setup
  ###############################

   #Include a profile that installs and configures Postfix:
  include profile::postfix::server

  #Include the profile that sets up my user account:
  include profile::users

  ###############################
  # Apache installation/setup
  ###############################

  #Install Apache so we can run Kibana and Grafana:
  include profile::apache

  ###############################
  # Riemann installation/setup
  ###############################

  #Install Java so we can run Riemann; use the -> arrow so that it gets instaleld:
  package {'openjdk-7-jdk':
    ensure => installed,
  }

  #Install Riemann
  include profile::riemann

  ###############################
  # InfluxDB installation/setup
  ###############################

  #Install InfluxDB
  include profile::influxdb

  ###############################
  # Grafana installation/setup
  ###############################

  #Include the Grafana profile
  include profile::grafana

  ###############################
  # Logstash installation/setup
  ###############################

  #Install Logstash...
  include profile::logstash
  #...and configure it:
  include profile::logstash::config

  ###############################
  # Elasticsearch installation/setup
  ###############################

  #Include Elasticsearch
  include profile::elasticsearch

  ###############################
  # Kibana installation/setup
  ###############################

  #Include the profile that sets up a virtual host for Kibana3:
  include profile::kibana3::apache_virtualhost

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client

  ###############################
  # Icinga 2 installation/setup
  ###############################
  
  #Install Icinga 2, set up a database for it
  #and collectd
  include role::icinga2::server 

  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

}

node 'dnsmailrelay.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client
 
  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

  ###############################
  # Icinga 2 host export stuff
  ###############################

  include profile::icinga2::hostexport

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  include profile::icinga2::nrpe::objects

  ###############################
  # Postfix installation/setup
  ###############################

   #Include a profile that installs and configures Postfix:
  include profile::postfix::server

  #Include the profile that sets up my user account:
  include profile::users

}

node 'dnsusermail.local' {

  ###############################
  # SSH installation/setup
  ###############################

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  ###############################
  # rsyslog installation/setup
  ###############################

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  ###############################
  # NTP installation/setup
  ###############################

  #Include a profile that sets up NTP
  include profile::ntp::client
 
  ###############################
  # collectd installation/setup
  ###############################

  #Install Collectd so we can get metrics from this machine into Riemann/InfluxDB:
  include profile::collectd
  
  #Gather NTP stats:
  include profile::collectd::system_metrics
  
  #Gather network metrics
  include profile::collectd::network_metrics
  
  #Send collectd metrics to the monitoring VM
  include profile::collectd::write_graphite

  ###############################
  # Icinga 2 host export stuff
  ###############################

  include profile::icinga2::hostexport

  ###############################
  # NRPE installation/configuration
  ###############################

  #Install and configure NRPE
  include profile::icinga2::nrpe
  
  #Include NRPE command definitions
  include profile::icinga2::nrpe::objects

  ###############################
  # Postfix installation/setup
  ###############################

   #Include a profile that installs and configures Postfix:
  include profile::postfix::server

  #Include the profile that sets up my user account:
  include profile::users

}
