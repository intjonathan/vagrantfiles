  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.79', '10.0.1.80', '10.0.1.85', '127.0.0.1'],
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
  
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }





 @@nagios_host { $::fqdn:
    address => $::ipaddress_eth1,
    check_command => 'check_ping!100.0,20%!500.0,60%',
    use => 'generic-host',
    hostgroups => ['ssh_servers'],
    target => "/etc/icinga/objects/hosts/host_${::fqdn}.cfg",
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.79', '10.0.1.80', '10.0.1.85', '127.0.0.1'],
  }

  #Some basic box health stuff
  icinga2::nrpe::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga2::nrpe::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga2::nrpe::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga2::nrpe::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga2::nrpe::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga2::nrpe::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga2::nrpe::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }

  @@icinga2::objects::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux-servers', 'mysqlservers', 'clients'],
    target_dir => '/etc/icinga2/conf.d/hosts',
    target_file_name => "${fqdn}.conf"
  }