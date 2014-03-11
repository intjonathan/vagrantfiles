#default node defition
node default {

  include ssh

}

#puppet master node definition
node 'icingamaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
  class { 'rsyslog::server': }
 
  include ssh

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#Ubuntu Icinga server node

node 'ubuntuicinga.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icingamaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'postgresql::server': }

  postgresql::server::db { 'icinga':
    user     => 'icingaidoutils',
    password => postgresql_password('icingaidoutils', 'password'),
  }

  class { 'icinga::server':
    server_db_password => 'password',
    server_users => ['icingaadmin', 'nick2', 'nick', 'nick3'],
  }
  
  #An Icinga web user:
  icinga::server::user { 'nick':
    password => 'password',
  }

  #Another Icinga web user:
  icinga::server::user { 'nick2':
    password => 'password1', 
  }

  #Another Icinga web user:
  icinga::server::user { 'nick3':
    password => 'password2', 
  }

  #nagios_command { 'check_ping':
  #  command_name => 'check_ping',# (namevar) The name of this nagios_command...
  #  ensure       => present,# The basic property that the resource should be...
  #  command_line => '$USER1$/check_ping -H $HOSTADDRESS$ -w $ARG1$ -c $ARG2$ -p 5',# Nagios configuration file...
  #  target       => '/etc/icinga/objects/commands/check_ping.cfg'
  #  # ...plus any applicable metaparameters.
  #}

  #Define this command first so that any other services can use it as part of their check commands:
  nagios_command { 'check_nrpe':
    command_name => 'check_nrpe',
    ensure       => present,
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$ -c $ARG1$ -t 20',
    target       => "/etc/icinga/objects/commands/check_nrpe.cfg",
    require      => Class['icinga::server'],
  }
  
  #Check to see if NRPE itself is running
  nagios_command { 'check_nrpe_service':
    command_name => 'check_nrpe_service',
    ensure       => present,
    command_line => '$USER1$/check_nrpe -H $HOSTADDRESS$',
    target       => "/etc/icinga/objects/commands/check_nrpe_service.cfg",
    require      => Class['icinga::server'],
  }

  nagios_host { 'generic-host':
    ensure                       => present,
    target                       => '/etc/icinga/objects/templates/generic-host.cfg',
    notifications_enabled        => '1',
    event_handler_enabled        => '1',
    flap_detection_enabled       => '1',
    failure_prediction_enabled   => '1',
    process_perf_data            => '1',
    retain_status_information    => '1',
    retain_nonstatus_information => '1',
    check_command                => 'check-host-alive',
    max_check_attempts           => '10',
    notification_interval        => '0',
    notification_period          => '24x7',
    notification_options         => 'd,u,r',
    contact_groups               => 'admins',
    register                     => '0', #Don't actually register this template
  }

  nagios_service { 'generic-service':
    ensure                       => present,
    target                       => '/etc/icinga/objects/templates/generic-service.cfg',
    active_checks_enabled        => '1', # Active service checks are enabled
    passive_checks_enabled       => '1', # Passive service checks are enabled/accepted
    parallelize_check            => '1', # Active service checks should be parallelized (disabling this can lead to major performance problems)
    obsess_over_service          => '1', # We should obsess over this service (if necessary)
    check_freshness              => '0', # Default is to NOT check service 'freshness'
    notifications_enabled        => '1', # Service notifications are enabled
    event_handler_enabled        => '1', # Service event handler is enabled
    flap_detection_enabled       => '1', # Flap detection is enabled
    failure_prediction_enabled   => '1', # Failure prediction is enabled
    process_perf_data            => '1', # Process performance data
    retain_status_information    => '1', # Retain status information across program restarts
    retain_nonstatus_information => '1', # Retain non-status information across program restarts
    notification_interval        => '0', # Only send notifications on status change by default.
    is_volatile                  => '0',  
    check_period                 => '24x7',
    normal_check_interval        => '5',  
    retry_check_interval         => '1', 
    max_check_attempts           => '4',  
    notification_period          => '24x7',  
    notification_options         => 'w,u,c,r',
    contact_groups               => 'admins',
    register                     => '0', # DONT REGISTER THIS DEFINITION - ITS NOT A REAL SERVICE, JUST A TEMPLATE!
  }

  nagios_timeperiod { '24x7':
    timeperiod_name => '24x7',
    alias           => '24 Hours A Day, 7 Days A Week',
    target          => '/etc/icinga/objects/timeperiods/24x7.cfg', #The file this timeperiod definition will get created in
    sunday          => '00:00-24:00',
    monday          => '00:00-24:00',
    tuesday         => '00:00-24:00',
    wednesday       => '00:00-24:00',
    thursday        => '00:00-24:00',
    friday          => '00:00-24:00',
    saturday        => '00:00-24:00',
  }

  nagios_hostgroup { 'ssh_servers':
    ensure         => present,
    target         => '/etc/icinga/objects/hostgroups/ssh_servers.cfg',
    hostgroup_name => 'ssh_servers',
    alias          => 'SSH servers',
  }

  nagios_contact { 'root':
    ensure                        => present,
    target                        => '/etc/icinga/objects/contacts/root.cfg',
    contact_name                  => 'root',
    service_notification_period   => '24x7',
    host_notification_period      => '24x7',
    service_notification_options  => 'w,u,c,r,f',
    host_notification_options     => 'd,u,r,f',
    service_notification_commands => 'notify-service-by-email',
    host_notification_commands    => 'notify-host-by-email',
    email                         => 'root@localhost',
  }

  nagios_contactgroup { 'admins':
    ensure               => present,
    target               => '/etc/icinga/objects/contactgroups/admins.cfg',
    contactgroup_name    => 'admins',
    alias                => 'Admins',
    members              => 'root',
  }

  #Collect all @@nagios_host resources from PuppetDB
  Nagios_host <<||>> {
    require => Class['icinga::server'],
  }

  #Service definition for checking that NRPE itself is running on a remote machine
  nagios_service { 'check_nrpe_service':
    ensure => present,
    target => '/etc/icinga/objects/services/check_nrpe_service.cfg',
    use => 'generic-service',
    hostgroup_name => 'ssh_servers',
    service_description => 'NRPE',
    check_command => 'check_nrpe_service',
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

}

node 'centosicinga.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icingamaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'icinga::client':
    nrpe_allowed_hosts => ['10.0.1.79', '127.0.0.1'],
  }

  icinga::client::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  icinga::client::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }

  @@nagios_host { $::fqdn:
    address => $::ipaddress_eth1,
    check_command => 'check_ping!100.0,20%!500.0,60%',
    use => 'generic-host',
    hostgroups => ['ssh_servers'],
    target => "/etc/icinga/objects/hosts/host_${::fqdn}.cfg",
  }

}

node 'icingaclient1.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icingamaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'icinga::client':
    nrpe_allowed_hosts => ['10.0.1.79', '127.0.0.1'],
  }

  icinga::client::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  icinga::client::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }

  @@nagios_host { $::fqdn:
    address => $::ipaddress_eth1,
    check_command => 'check_ping!100.0,20%!500.0,60%',
    use => 'generic-host',
    hostgroups => ['ssh_servers'],
    target => "/etc/icinga/objects/hosts/host_${::fqdn}.cfg",
  }

}

node 'icingaclient2.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icingamaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  class { 'icinga::client':
    nrpe_allowed_hosts => ['10.0.1.79', '127.0.0.1'],
  }

  icinga::client::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  icinga::client::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }

  @@nagios_host { $::fqdn:
    address => $::ipaddress_eth1,
    check_command => 'check_ping!100.0,20%!500.0,60%',
    use => 'generic-host',
    hostgroups => ['ssh_servers'],
    target => "/etc/icinga/objects/hosts/host_${::fqdn}.cfg",
  }

}

node 'icingaclient3.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icingamaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'icinga::client':
    nrpe_allowed_hosts => ['10.0.1.79', '127.0.0.1'],
  }

  icinga::client::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  icinga::client::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }

  @@nagios_host { $::fqdn:
    address => $::ipaddress_eth1,
    check_command => 'check_ping!100.0,20%!500.0,60%',
    use => 'generic-host',
    hostgroups => ['ssh_servers'],
    target => "/etc/icinga/objects/hosts/host_${::fqdn}.cfg",
  }

}

node 'icingaclient4.local' {

  include ssh

  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icingamaster.local',
    port           => '514',
  }

  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  class { 'icinga::client':
    nrpe_allowed_hosts => ['10.0.1.79', '127.0.0.1'],
  }

  icinga::client::command { 'check_users':
    nrpe_plugin_name => 'check_users',
    nrpe_plugin_args => '-w 5 -c 10',
  }
  
  icinga::client::command { 'check_ntp_time':
    nrpe_plugin_name => 'check_ntp_time',
    nrpe_plugin_args => '-H 127.0.0.1',
  }

  @@nagios_host { $::fqdn:
    address => $::ipaddress_eth1,
    check_command => 'check_ping!100.0,20%!500.0,60%',
    use => 'generic-host',
    hostgroups => ['ssh_servers'],
    target => "/etc/icinga/objects/hosts/host_${::fqdn}.cfg",
  }

}