#default node defition
node default {

}

#puppet master node definition
node 'icingamaster.local' {

  class { 'puppetdb':
    listen_address => '10.0.1.79'
  }
  
 include puppetdb::master::config

}