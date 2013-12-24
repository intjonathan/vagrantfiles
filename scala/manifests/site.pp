#Node definitions
node 'scalamaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }

  include puppetdb::master::config

}

node 'ubuntuscala.local' {

  class{ 'scala':
    version => '2.10.2',
  }

  package {'openjdk-7-jdk':
    ensure => installed,
  }

}

node 'centosscala.local' {

  class{ 'scala':
    version => '2.10.2',
  }

}


node 'debianscala.local' {

  class{ 'scala':
    version => '2.10.2',
  }

  package {'openjdk-7-jdk':
    ensure => installed,
  }

}