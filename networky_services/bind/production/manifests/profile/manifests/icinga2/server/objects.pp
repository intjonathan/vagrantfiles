class profile::icinga2::server::objects {

  #Create a linux_servers hostgroup:
  icinga2::object::hostgroup { 'linux_servers':
    display_name => 'Linux servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a clients hostgroup:
  icinga2::object::hostgroup { 'icinga2_clients':
    display_name => 'Icinga 2 client machines',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an ssh_servers hostgroup:
  icinga2::object::hostgroup { 'ssh_servers':
    display_name => 'Servers running SSH',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a dns_servers hostgroup:
  icinga2::object::hostgroup { 'dns_servers':
    display_name => 'DNS servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

}


  #Create an apply that checks the number of total processes:
  icinga2::object::apply_service_to_host { 'check_total_procs':
    display_name => 'Total procs',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
      nrpe_command => 'check_total_procs',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }