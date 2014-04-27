#Node definitions

node 'antmaster.local' {

  #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
  
  class{ 'ant':
      version => '1.9.2',
  }

}

node 'antubuntu.local' {

  class{ 'ant':
      version => '1.9.2',
  }
  
 package {'openjdk-7-jdk':
    ensure => installed,
  }

  class {'gradle':
        version => '1.9',
  }
  
  class {'groovy':
    version => '2.2.1',
  }
 
}

node 'antdebian.local' {
  
  class{ 'ant':
      version => '1.9.2',
  }

 package {'openjdk-7-jdk':
    ensure => installed,
  }

  class {'gradle':
        version => '1.9',
  }
  
  class {'groovy':
    version => '2.2.1',
  }

}

node 'antcentos.local' {

  class{ 'ant':
      version => '1.9.2',
  }

  class {'gradle':
        version => '1.9',
  }
  
  class {'groovy':
    version => '2.2.1',
  }

}