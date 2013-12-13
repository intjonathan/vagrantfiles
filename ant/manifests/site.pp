#Node definitions

node 'antmaster.local' {

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
 
}

node 'antdebian.local' {
  
  class{ 'ant':
      version => '1.9.2',
  }
  
}

node 'antcentos.local' {
  
}