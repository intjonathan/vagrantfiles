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
  
  #Make this machine a Consul server for all of the Icinga 2 client and server VMs
  include profile::consul::server

}

node 'logstash.local' {
 
  #Install Apache so we use Kibana 3:
  include profile::apache

  #Install Java...
  include profile::java

  #Include Logstash
  include profile::logstash
  include profile::logstash::config


}

node 'kibana.local' {
  
  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

  #Install Apache so we use Kibana 3:
  include profile::apache

  #Include the profile that sets up a virtual host for Kibana 3:
  include profile::kibana3::apache_virtualhost

  #Include the profile that sets up a virtual host for Kibana 4:
  include profile::kibana4::apache_virtualhost

  #Make this machine a Consul client:
  include profile::consul::client

}

node 'elasticsearch1.local' {

  #Include Elasticsearch
  include profile::elasticsearch

  #Install Java...
  include profile::java

}

node 'elasticsearch2.local' {

  #Include Elasticsearch
  include profile::elasticsearch

  #Install Java...
  include profile::java

}

node 'elasticsearch3.local' {

  #Include Elasticsearch
  include profile::elasticsearch

  #Install Java...
  include profile::java

}

node 'elasticsearch4.local' {

  #Include Elasticsearch
  include profile::elasticsearch

  #Install Java...
  include profile::java

}

node 'rsyslog1.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

}

node 'rsyslog2.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

}

node 'rsyslog3.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

}

node 'logstashmetrics.local' {

  #Include the rsyslog::client profile to set up logging
  include profile::rsyslog::client

}