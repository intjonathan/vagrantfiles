#default node defition
node default {

}

#puppet master node definition
node 'icingamaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
 include puppetdb::master::config

}