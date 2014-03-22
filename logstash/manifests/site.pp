#Node definitions

node 'logstashmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
  
  include ssh

}

node 'logstash.local' {
  
  include ssh

}

node 'kibanathree.local' {

  include ssh
  
}

node 'elasticsearch1.local', 'elasticsearch2.local', 'elasticsearch3.local', 'elasticsearch4.local' {
  
  include ssh
  
}

node 'rsyslog1.local', 'rsyslog2.local' {

  include ssh

}