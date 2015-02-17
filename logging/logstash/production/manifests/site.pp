#Node definitions

node 'logstashmaster.local' {

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
  
  #Make this machine a Consul server:
  include profile::consul::server

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'logstash.local' {
 
  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client
 
  #Install Apache so we use Kibana 3:
  include profile::apache

  #Install Java...
  include profile::java

  #Include Logstash
  include profile::logstash
  include profile::logstash::config

  #Make this machine a Consul server:
  include profile::consul::server

  #Include a profile that installs and configures Postfix:
  include profile::postfix::server

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'kibana.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client
  
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Install Apache so we use Kibana 3 and 4:
  include profile::apache

  #Include the profile that sets up a virtual host for Kibana 3:
  include profile::kibana3::apache_virtualhost

  #Include the profile that sets up a virtual host for Kibana 4:
  include profile::kibana4::apache_virtualhost

  #Make this machine a Consul server:
  include profile::consul::server

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'elasticsearch1.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include Elasticsearch
  include profile::elasticsearch

  #Install Java...
  include profile::java

  #Make this machine a Consul client:
  include profile::consul::client

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'elasticsearch2.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include Elasticsearch
  include profile::elasticsearch

  #Install Java...
  include profile::java

  #Make this machine a Consul client:
  include profile::consul::client

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'elasticsearch3.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include Elasticsearch
  include profile::elasticsearch

  #Install Java...
  include profile::java

  #Make this machine a Consul client:
  include profile::consul::client

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'rsyslog1.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Make this machine a Consul client:
  include profile::consul::client

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'rsyslog2.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Make this machine a Consul client:
  include profile::consul::client

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'rsyslog3.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Make this machine a Consul client:
  include profile::consul::client

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

}

node 'logstashmetrics.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Make this machine a Consul client:
  include profile::consul::client

  #Include a profile that installs and configures Postfix:
  include profile::postfix::server

  #Install Apache so we use Grafana:
  include profile::apache

  #Install Java...
  include profile::java

  #Install Riemann
  include profile::riemann

  #Install InfluxDB
  include profile::influxdb

  #Include the Grafana profile
  include profile::grafana

}

node 'logstashdns.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Make this machine a Consul client:
  include profile::consul::client

  #Install ColllectD, gather some system metrics and write them to the metrics VM:
  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::write_graphite

  #Install BIND and some sample zone data files:
  #include profile::bind::master

}