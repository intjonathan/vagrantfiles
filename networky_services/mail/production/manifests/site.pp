#puppet master node definition
node 'mailpuppetmaster.local' {

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

node 'mailrelay.local' {

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

node 'mailserver.local' {

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

node 'maildns.local' {

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
  
  include profile::bind::master

}

node 'mailmonitoring.local' {

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

node 'usermail.local' {

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
