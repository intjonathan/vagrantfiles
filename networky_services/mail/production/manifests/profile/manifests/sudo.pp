class profile::sudo {


  ::sudo::conf { 'admin':
    priority => 10,
    content  => "%admin ALL=(ALL) NOPASSWD: ALL",
  }

  ::sudo::conf { 'sudo':
    priority => 20,
    content  => "%sudo ALL=(ALL) NOPASSWD: ALL",
  }

  #Create a sudoers rule for the vagrant user so it can run sudo commands without needing
  #to give a password:
  ::sudo::conf { 'vagrant':
    priority => 20,
    content  => "vagrant ALL=NOPASSWD:ALL",
  }

}