node 'puppet.local' {
  
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }

  include puppetdb::master::config  

  class {'serf':
    version => '0.2.1',
  }

}

node 'ubuntuserf.local' {
  class {'serf':
    version => '0.2.1',
  }
}


node 'centosserf.local' {
  class {'serf':
    version => '0.2.1',
  }
}