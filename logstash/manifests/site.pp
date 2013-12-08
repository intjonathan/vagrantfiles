#Node definitions

node 'logstash.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config 
 
}


node 'elasticsearch1.local', 'elasticsearch2.local' {

}


node 'kibanathree.local' {

}

node 'rsyslog1.local', 'rsyslog2.local' {

}