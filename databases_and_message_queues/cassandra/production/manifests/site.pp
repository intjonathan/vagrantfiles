#puppet master node definition
node 'cassandramaster.local' {

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

  #Set up Hiera:
  include profile::hiera

  #Include the role that sets up CollectD, sets it up to gather system and
  #sends it to a Graphite (in this case, Riemann) server:
  include role::collectd::collectd_system_metrics_and_write_graphite

  #Make this machine a Consul server:
  include profile::consul::server

  #Install cassandra and configure it with some plugins:
  include profile::heka

}

node 'cassandra1.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Make this machine a Consul client:
  include profile::consul::client

  #Include the role that sets up CollectD, sets it up to gather system and
  #sends it to a Graphite (in this case, Riemann) server:
  include role::collectd::collectd_system_metrics_and_write_graphite

  #Install cassandra and configure it with some plugins:
  include profile::heka

  #Install Java via the Java profile
  #include profile::java

}

node 'cassandra2.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Make this machine a Consul client:
  include profile::consul::client

  #Install cassandra and configure it with some plugins:
  include profile::heka

  #Install Java via the Java profile
  #include profile::java

  #Include the role that sets up CollectD, sets it up to gather system and
  #sends it to a Graphite (in this case, Riemann) server:
  include role::collectd::collectd_system_metrics_and_write_graphite

}

node 'cassandra3.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Make this machine a Consul client:
  include profile::consul::client

  #Install cassandra and configure it with some plugins:
  include profile::heka

  #Install Java via the Java profile
  #include profile::java

  #Include the role that sets up CollectD, sets it up to gather system and
  #sends it to a Graphite (in this case, Riemann) server:
  include role::collectd::collectd_system_metrics_and_write_graphite

}

node 'cassandramonitoring.local' {

  #Include a profile that sets up our usual SSH settings:
  include profile::ssh
  
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Include a profile that sets up NTP
  include profile::ntp::client

  #Include the role that sets up CollectD, sets it up to gather system and
  #sends it to a Graphite (in this case, Riemann) server:
  include role::collectd::collectd_system_metrics_and_write_graphite

  #Include the Apache profile so we can set up Grafana and Kibana 3 with it:
  include profile::apache
  
  #Install Java via the Java profile
  include profile::java

  #Include Elasticsearch
  include profile::elasticsearch
  
  #Install Riemann
  include profile::riemann
  
  #Install InfluxDB
  include profile::influxdb
  
  #Include the Grafana profile
  include profile::grafana

  #Include Logstash
  include profile::logstash
  include profile::logstash::config

  #Include Elasticsearch
  include profile::elasticsearch

  #Include the profile that sets up a virtual host for Kibana3:
  include profile::kibana3::apache_virtualhost

  #Include a profile that installs and configures Postfix:
  include profile::postfix

  #Include the profile that sets up my user account:
  include profile::users

  #Make this machine a Consul client:
  include profile::consul::client

  #Install cassandra and configure it with some plugins:
  include profile::heka

}