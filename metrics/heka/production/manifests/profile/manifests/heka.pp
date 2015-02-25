class profile::heka {

  class { '::heka':
  }


  ::heka::plugin::input::tcpinput { 'tcpinput1':
    refresh_heka_service => true,
    address => "${::ipaddress_lo}:5565"
  }

  ::heka::plugin::input::tcpinput { 'tcpinput2':
    refresh_heka_service => true,
    address => "${::ipaddress_lo}:5566"
  }

  ::heka::plugin::input::tcpinput { 'tcpinput3':
    refresh_heka_service => true,
    address => "${::ipaddress_lo}:5567"
  }

  ::heka::plugin::input::udpinput { 'udpinput1':
    refresh_heka_service => true,
    address => "${::ipaddress_lo}:4880"
  }

}