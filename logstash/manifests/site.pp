#Node definitions

node 'logstash.local' {
  
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }

}
  include puppetdb::master::config 

node 'elasticsearch1', 'elasticsearch2' {

}
