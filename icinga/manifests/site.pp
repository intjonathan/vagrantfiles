node default {

}

node 'icingamaster.local' {

  class { 'puppetdb':
    listen_address => '10.0.1.79'
  }
  
 include puppetdb::master::config

}