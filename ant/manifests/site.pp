#Node definitions

node 'antmaster.local' {

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