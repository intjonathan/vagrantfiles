#default node defition
node default {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

}

#puppet master node definition
node 'icinga2master.local' {

  #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
  
  #Apache modules for PuppetBoard:
  class { 'apache': }
  class { 'apache::mod::wsgi': }

  #Configure Puppetboard with this module: https://github.com/nibalizer/puppet-module-puppetboard
  class { 'puppetboard':
    manage_virtualenv => true,
  }

  #A virtualhost for PuppetBoard
  class { 'puppetboard::apache::vhost':
    vhost_name => "puppetboard.${fqdn}",
    port => 80,
  }
 
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::server':
    enable_tcp => true,
    enable_udp => true,
    port       => '5514',
    server_dir => '/var/log/remote/',
  }
 
  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#Ubuntu Trusty Icinga2 server node
node 'trustyicinga2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
    grant => 'all',
  }

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    owner    => 'icinga2',
    password => postgresql_password('icingaweb2', 'password'),
  }

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    server_install_nagios_plugins => false,
  } ->

  #Collect all @@icinga2::object::host resources from PuppetDB that were exported by other machines:
  Icinga2::Object::Host <<| |>> { }

  #Create a linux_servers hostgroup:
  icinga2::object::hostgroup { 'linux_servers':
    display_name => 'Linux servers',
    groups => ['mysql_servers', 'clients'],
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a mysql_servers hostgroup:
  icinga2::object::hostgroup { 'mysql_servers':
    display_name => 'MySQL servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a clients hostgroup:
  icinga2::object::hostgroup { 'clients':
    display_name => 'Client machines',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an SMTP servers hostgroup
  icinga2::object::hostgroup { 'smtp_servers':
    display_name => 'SMTP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an apply that checks SSH:
  icinga2::object::apply_service_to_host { 'check_ssh':
    display_name => 'SSH',
    check_command => 'ssh',
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks SMTP:
  icinga2::object::apply_service_to_host { 'check_smtp':
    display_name => 'SMTP',
    check_command => 'smtp',
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks load average:
  icinga2::object::apply_service_to_host { 'load_average':
    display_name => 'Load average',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_load',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of users:
  icinga2::object::apply_service_to_host { 'check_users':
    display_name => 'Logged in users',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_users',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks disk space on /:
  icinga2::object::apply_service_to_host { 'check_disk':
    display_name => 'Disk space on /',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_disk',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of total processes:
  icinga2::object::apply_service_to_host { 'check_total_procs':
    display_name => 'Total procs',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_total_procs',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of zombie processes:
  icinga2::object::apply_service_to_host { 'check_zombie_procs':
    display_name => 'Zombie procs',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_zombie_procs',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks MySQL:
  icinga2::object::apply_service_to_host { 'check_mysql_service':
    display_name => 'MySQL',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_mysql_service',
    },
    assign_where => '"mysql_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
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

}

#Ubuntu Precise Icinga2 server node
node 'preciseicinga2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
  }

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => postgresql_password('icingaweb2', 'password'),
  }

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

 #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    server_install_nagios_plugins => false,
  } ->

  #Collect all @@icinga2::object::host resources from PuppetDB that were exported by other machines:
  Icinga2::Object::Host <<| |>> { }

  #Create a linux_servers hostgroup:
  icinga2::object::hostgroup { 'linux_servers':
    display_name => 'Linux servers',
    groups => ['mysql_servers', 'clients'],
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a mysql_servers hostgroup:
  icinga2::object::hostgroup { 'mysql_servers':
    display_name => 'MySQL servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a clients hostgroup:
  icinga2::object::hostgroup { 'clients':
    display_name => 'Client machines',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
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

}

#CentOS Icinga 2 server node
node 'centosicinga2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
  }

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => postgresql_password('icingaweb2', 'password'),
  }

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

 #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    server_install_nagios_plugins => false,
  } ->

  #Collect all @@icinga2::object::host resources from PuppetDB that were exported by other machines:
  Icinga2::Object::Host <<| |>> { }

  #Create a linux_servers hostgroup:
  icinga2::object::hostgroup { 'linux_servers':
    display_name => 'Linux servers',
    groups => ['mysql_servers', 'clients'],
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a mysql_servers hostgroup:
  icinga2::object::hostgroup { 'mysql_servers':
    display_name => 'MySQL servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create a clients hostgroup:
  icinga2::object::hostgroup { 'clients':
    display_name => 'Client machines',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an apply that checks load average:
  icinga2::object::apply_service_to_host { 'load_average':
    display_name => 'Load average',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_load',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of users:
  icinga2::object::apply_service_to_host { 'check_users':
    display_name => 'Logged in users',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_users',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks disk space on /:
  icinga2::object::apply_service_to_host { 'check_disk':
    display_name => 'Disk space on /',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_disk',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of total processes:
  icinga2::object::apply_service_to_host { 'check_total_procs':
    display_name => 'Total procs',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_total_procs',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks the number of zombie processes:
  icinga2::object::apply_service_to_host { 'check_zombie_procs':
    display_name => 'Zombie procs',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_zombie_procs',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks MySQL:
  icinga2::object::apply_service_to_host { 'check_mysql_service':
    display_name => 'MySQL',
    check_command => 'nrpe',
    vars => {
      nrpe_command => 'check_mysql_service',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
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

}

node 'icinga2client1.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install some stuff to monitor like...
  
  #...Apache:
  class{ '::apache':}
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'rewrite': } #Install/enable the rewrite module
  
  #Install Postgres so we can monitor it with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres test DB for Icinga 2 to monitor:
  postgresql::server::db { 'test_data':
    user     => 'tester',
    password => postgresql_password('tester', 'password'),
  }

  #Create a MySQL test database for Icinga 2 to monitor:
  mysql::db { 'test_data':
    user     => 'test',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
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

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'mysql_servers', 'clients', 'smtp_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

node 'icinga2client2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  #Install some stuff to monitor like...
  
  #...Apache:
  class{ '::apache':}
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
 
  #Install Postgres so we can monitor it with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres test DB for Icinga 2 to monitor:
  postgresql::server::db { 'test_data':
    user     => 'tester',
    password => postgresql_password('tester', 'password'),
  }

  #Create a MySQL test database for Icinga 2 to monitor:
  mysql::db { 'test_data':
    user     => 'test',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  #Install BIND 9 so we can monitor DNS.
  #BIND module is from: https://github.com/thias/puppet-bind
  include bind
  bind::server::conf { '/etc/named.conf':
    acls => {
      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ],
      'local'   => [ '127.0.0.1' ],
      '10net'   => [ '10.0.0.0/24', '10.0.1.0/24', '10.1.1.0/24', '10.1.0.0/24'],
    },
    directory => '/var/named',
    listen_on_addr    => [ '127.0.0.1' ],
    listen_on_v6_addr => [ '::1' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localhost', 'local', '10net'],
    recursion         => 'yes',
    allow_recursion   => [ 'localhost', 'local', '10net'],
    #Include some other zone files and root keys.
    includes => ['/etc/named.root.key'],
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

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'mysql_servers', 'clients', 'smtp_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

node 'icinga2client3.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #...Apache:
  class{ '::apache':}
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'rewrite': } #Install/enable the rewrite module
  
  #Install Postgres so we can monitor it with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres test DB for Icinga 2 to monitor:
  postgresql::server::db { 'test_data':
    user     => 'tester',
    password => postgresql_password('tester', 'password'),
  }

  #Create a MySQL test database for Icinga 2 to monitor:
  mysql::db { 'test_data':
    user     => 'test',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
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

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'mysql_servers', 'clients', 'smtp_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

node 'icinga2client4.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  #...Apache:
  class{ '::apache':}
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  
  #Install Postgres so we can monitor it with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres test DB for Icinga 2 to monitor:
  postgresql::server::db { 'test_data':
    user     => 'tester',
    password => postgresql_password('tester', 'password'),
  }

  #Create a MySQL test database for Icinga 2 to monitor:
  mysql::db { 'test_data':
    user     => 'test',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
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

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'mysql_servers', 'clients', 'smtp_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

node 'icinga2mail.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install some stuff to monitor like...
  
  #...Apache:
  class{ '::apache':}
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'rewrite': } #Install/enable the rewrite module
  
  #Install Postgres so we can monitor it with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres test DB for Icinga 2 to monitor:
  postgresql::server::db { 'test_data':
    user     => 'tester',
    password => postgresql_password('tester', 'password'),
  }

  #Create a MySQL test database for Icinga 2 to monitor:
  mysql::db { 'test_data':
    user     => 'test',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
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

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'mysql_servers', 'clients', 'smtp_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

node 'usermail.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    #Export host keys to PuppetDB:
    storeconfigs_enabled => true,
    server_options => {
      #Whether to allow password auth; if set to 'no', only SSH keys can be used:
      #'PasswordAuthentication' => 'no',
      #How many authentication attempts to allow before disconnecting:
      'MaxAuthTries'         => '10',
      'PermitEmptyPasswords' => 'no', 
      'PermitRootLogin'      => 'no',
      'Port'                 => [22],
      'PubkeyAuthentication' => 'yes',
      #Whether to be strict about the permissions on a user's .ssh/ folder and public keys:
      'StrictModes'          => 'yes',
      'TCPKeepAlive'         => 'yes',
      #Whether to do reverse DNS lookups of client IP addresses when they connect:
      'UseDNS'               => 'no',
    },
  }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'icinga2master.local',
    port           => '5514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install some stuff to monitor like...
  
  #...Apache:
  class{ '::apache':}
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'rewrite': } #Install/enable the rewrite module
  
  #Install Postgres so we can monitor it with Icinga 2...
  class { 'postgresql::server': }

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a Postgres test DB for Icinga 2 to monitor:
  postgresql::server::db { 'test_data':
    user     => 'tester',
    password => postgresql_password('tester', 'password'),
  }

  #Create a MySQL test database for Icinga 2 to monitor:
  mysql::db { 'test_data':
    user     => 'test',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.0.0/16',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  #Create a user account so we can test receiving mail:
  user { 'nick':
    ensure => present,
    home => '/home/nick',
    groups => ['sudo', 'admin'],
    #This is 'password', in salted SHA-512 form:
    password => '$6$IPYwCTfWyO$bIVTSw4ai/BGtZpfI4HtC8XE7bmb8b3kdZ6gRz4DF4hm7WmD35azXoFxN90TRrSYQdKo011YnBl7p3UXR2osQ1',
    shell => '/bin/bash',
  }

  file { '/home/nick' :
    ensure => directory,
    owner => 'nick',
    group => 'nick',
    mode =>  '755',
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

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    groups => ['linux_servers', 'mysql_servers', 'clients', 'smtp_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}