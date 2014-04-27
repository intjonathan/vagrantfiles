  class { 'icinga::server':
    server_db_password => 'password',
    server_users => ['icinga2admin', 'nick2', 'nick', 'nick3'],
  }
  
  #An icinga2 web user:
  icinga::server::user { 'nick':
    password => 'password',
  }

  #Another icinga2 web user:
  icinga::server::user { 'nick2':
    password => 'password1', 
  }

  #Another icinga2 web user:
  icinga::server::user { 'nick3':
    password => 'password2', 
  }

  #Collect all @@nagios_host resources from PuppetDB that were exported by other machines:
  Nagios_host <<||>> { }

  nagios_host { 'linux_host':
    ensure   => present,
    target   => '/etc/icinga/objects/templates/linux_host.cfg',
    name     => 'linux_host',
    use      => 'generic-host',
    register => '0', #Don't actually register this template    
  }
  
  nagios_host { 'ubuntu_host':
    ensure => present,
    target => '/etc/icinga/objects/templates/ubuntu_host.cfg',
    name   => 'ubuntu_host',
    use    => 'linux_host',
    register => '0', #Don't actually register this template    
  }

  nagios_host { 'centos_host':
    ensure => present,
    target => '/etc/icinga/objects/templates/centos_host.cfg',
    name   => 'centos_host',
    use    => 'linux_host',
    register => '0', #Don't actually register this template    
  }

  nagios_host { 'windows_host':
    ensure   => present,
    target   => '/etc/icinga/objects/templates/windows_host.cfg',
    name     => 'windows_host',
    use      => 'generic-host',
    register => '0', #Don't actually register this template    
  }

  nagios_hostgroup { 'ssh_servers':
    ensure         => present,
    target         => '/etc/icinga/objects/hostgroups/ssh_servers.cfg',
    hostgroup_name => 'ssh_servers',
    alias          => 'SSH servers',
  }

#######################################
# Icinga server monitoring snippets
#######################################

#Define this command first so that any other services can use it as part of their check commands:
  nagios_command { 'check_nrpe':
    command_name => 'check_nrpe',
    ensure       => present,
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 20',
    target       => "/etc/icinga/objects/commands/check_nrpe.cfg",
  }
  
  #Check to see if NRPE itself is running on a remote machine:
  nagios_command { 'check_nrpe_service':
    command_name => 'check_nrpe_service',
    ensure       => present,
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$',
    target       => "/etc/icinga/objects/commands/check_nrpe_service.cfg",
  }

  #Check to see if SSH is running on a remote machine:
  nagios_command { 'check_ssh':
    command_name => 'check_ssh',
    ensure       => present,
    command_line => '$USER1$/check_ssh $HOSTADDRESS$',
    target       => "/etc/icinga/objects/commands/check_ssh.cfg",
  }

  #Service definition for checking that NRPE itself is running on a remote machine; this uses
  #the check_nrpe_service nagios_command defined above:
  nagios_service { 'check_nrpe_service':
    ensure => present,
    target => '/etc/icinga/objects/services/check_nrpe_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'NRPE',
    check_command => 'check_nrpe_service',
  }

  #Service definition for checking SSH
  nagios_service { 'check_ssh_service':
    ensure => present,
    target => '/etc/icinga/objects/services/check_ssh_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'SSH',
    check_command => 'check_ssh',
  }

  #Service definition for checking NTP on machines via NRPE
  nagios_service { 'check_ntp_time':
    ensure => present,
    target => '/etc/icinga/objects/services/check_ntp_time.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'NTP offset',
    check_command => 'check_nrpe!check_ntp_time',
  }

  #Service definition for checking MySQL on machines via NRPE
  nagios_service { 'check_mysql_service':
    ensure => present,
    target => '/etc/icinga/objects/services/check_mysql_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'MySQL',
    check_command => 'check_nrpe!check_mysql_service',
  }
  
  #check_users
  nagios_service { 'check_users':
    ensure => present,
    target => '/etc/icinga/objects/services/check_users_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'Users',
    check_command => 'check_nrpe!check_users',
  }

  #check_users
  nagios_service { 'check_load':
    ensure => present,
    target => '/etc/icinga/objects/services/check_load_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'Load',
    check_command => 'check_nrpe!check_load',
  }

  #check_users
  nagios_service { 'check_disk':
    ensure => present,
    target => '/etc/icinga/objects/services/check_disk_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'Disk',
    check_command => 'check_nrpe!check_disk',
  }

  #check_users
  nagios_service { 'check_total_procs':
    ensure => present,
    target => '/etc/icinga/objects/services/check_total_procs_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'Total procs',
    check_command => 'check_nrpe!check_total_procs',
  }

  #check_users
  nagios_service { 'check_zombie_procs':
    ensure => present,
    target => '/etc/icinga/objects/services/check_zombie_procs_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'Zombie procs',
    check_command => 'check_nrpe!check_zombie_procs',
  }

#######################################
# Icinga client monitoring snippets
#######################################

 #Install some stuff to monitor like...
  
  #...Apache:
  class{ '::apache':}
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'rewrite': } #Install/enable the rewrite module
  
  #...and MySQL:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

 @@nagios_host { $::fqdn:
    address => $::ipaddress_eth1,
    check_command => 'check_ping!100.0,20%!500.0,60%',
    use => 'generic-host',
    hostgroups => ['ssh_servers'],
    target => "/etc/icinga/objects/hosts/host_${::fqdn}.cfg",
  }

  class { 'icinga::client':
    nrpe_allowed_hosts => ['10.0.1.79', '127.0.0.1'],
  }

#Some basic box health stuff
  icinga::client::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  #check_load
  icinga::client::command { 'check_load':
    nrpe_plugin_name => 'check_load',
    nrpe_plugin_args => '-w 50,40,30 -c 60,50,40',
  }
  
  #check_disk
  icinga::client::command { 'check_disk':
    nrpe_plugin_name => 'check_disk',
    nrpe_plugin_args => '-w 20% -c 10% -p /',
  }

  #check_total_procs  
  icinga::client::command { 'check_total_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 1000 -c 1500',
  }
 
  #check_zombie_procs
  icinga::client::command { 'check_zombie_procs':
    nrpe_plugin_name => 'check_procs',
    nrpe_plugin_args => '-w 5 -c 10 -s Z',
  }
  
  icinga::client::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }
  
  #Create an NRPE command to monitor MySQL:
  icinga::client::command { 'check_mysql_service':
    nrpe_plugin_name => 'check_mysql',
    nrpe_plugin_args => '-H 127.0.0.1 -u root -p horsebatterystaple',
  }