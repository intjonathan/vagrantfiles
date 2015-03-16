class profile::heka {

  class { '::heka':
    global_config_settings => {
      'poolsize' => 10000,
      'hostname' => "\"${::fqdn}\"",
    },
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

  ::heka::plugin { 'tcpinput4':
    refresh_heka_service => true,
    type => 'TcpInput',
    settings => {
      'address' => '"127.0.0.1:556"',
    },
  }

  ::heka::plugin::input::statsdinput { 'statsdinput1':
   refresh_heka_service => true,
   address => '0.0.0.0:8125',
   stat_accum_name => 'stataccuminput1',
  }

  ::heka::plugin::input::stataccuminput { 'stataccuminput1':
    refresh_heka_service => true,
    ticker_interval => 1,
    emit_in_fields => true,
  }

  ::heka::plugin::output::carbonoutput { 'carbonoutput1':
    address => 'cassandramonitoring.local:2003',
    message_matcher => "Type == 'cassandra.statmetric'",
    protocol => 'udp',
  }

  ::heka::plugin { 'dashboard1':
    type => 'DashboardOutput',
    settings => {
      'address' => '"0.0.0.0:4352"',
      'ticker_interval' => 6,
    },
  }

  ::heka::plugin { 'dashboard2':
    type => 'DashboardOutput',
    settings => {
      'address' => '"0.0.0.0:4353"',
      'ticker_interval' => 6,
    },
  }

  ::heka::plugin { 'dashboard3':
    type => 'DashboardOutput',
    settings => {
      'address' => '"0.0.0.0:4354"',
      'ticker_interval' => 6,
    },
  }

}