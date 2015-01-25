class profile::sudo {


  ::sudo::conf { 'admin':
    priority => 10,
    content  => "%admin ALL=(ALL) NOPASSWD: ALL",
  }


  ::sudo::conf { 'sduo':
    priority => 20,
    content  => "%sudo ALL=(ALL) NOPASSWD: ALL",
  }

}