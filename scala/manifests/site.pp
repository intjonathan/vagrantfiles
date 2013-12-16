#Node definitions
node 'scalamaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
  
  class{ 'ant':
      version => '1.9.2',
  }

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