#puppet master node definition
node 'dockermaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config

}

#Ubuntu Docker machine
node 'docker1.local' {

}

#Ubuntu Docker machine
node 'docker2.local' {

}

#Ubuntu Docker machine
node 'docker3.local' {

}