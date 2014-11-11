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
  class { 'rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
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

#An Ubuntu 14.04 Icinga2 server node
node 'trustyicinga2server.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #Make rsyslog watch the Apache log files:
  rsyslog::imfile { 'apache-access':
    file_name => '/var/log/apache2/access.log',
    file_tag => 'apache-access',
    file_facility => 'local7',
    file_severity => 'info',
  }

  rsyslog::imfile { 'apache-error':
    file_name => '/var/log/apache2/error.log',
    file_tag => 'apache-errors',
    file_facility => 'local7',
    file_severity => 'error',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': } ->

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  } ->

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
    grant => 'all',
  } ->

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => postgresql_password('icingaweb2', 'password'),
    grant => 'all',
  } ->

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    db_user        => 'icinga2',
    db_name        => 'icinga2_data',
    db_password    => 'password',
    db_host        => '127.0.0.1',
    db_port        => '5432',
    server_install_nagios_plugins => false,
    install_mail_utils_package => true,
    server_enabled_features  => ['checker','notification', 'livestatus', 'syslog'],
    server_disabled_features => ['graphite', 'api'],
  } ->

  #Collect all @@icinga2::object::host resources from PuppetDB that were exported by other machines:
  Icinga2::Object::Host <<| |>> { }

  #Create a linux_servers hostgroup:
  icinga2::object::hostgroup { 'linux_servers':
    display_name => 'Linux servers',
    groups => ['mysql_servers', 'clients'],
    target_dir => '/etc/icinga2/objects/hostgroups',
    assign_where => 'match("*redis*", host.name) || match("*elastic*", host.name) || match("*logstash*", host.name)',
  }

  #Create a mysql_servers hostgroup:
  icinga2::object::hostgroup { 'mysql_servers':
    display_name => 'MySQL servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Postgres IDO connection object:
  icinga2::object::idopgsqlconnection { 'testing_postgres':
     host             => '127.0.0.1',
     port             => 5432,
     user             => 'icinga2',
     password         => 'password',
     database         => 'icinga2_data',
     target_file_name => 'ido-pgsql.conf',
     target_dir       => '/etc/icinga2/features-enabled',
     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

#  #MySQL IDO connection object
#  icinga2::object::idomysqlconnection { 'testing_mysql':
#     host             => '127.0.0.1',
#     port             => 3306,
#     user             => 'icinga2',
#     password         => 'password',
#     database         => 'icinga2_data',
#     target_file_name => 'ido-mysql.conf',
#     target_dir       => '/etc/icinga2/features-enabled',
#     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
#  }

  #Create a sysloglogger object:
  icinga2::object::sysloglogger { 'syslog-warning':
    severity => 'warning',
    target_dir => '/etc/icinga2/features-enabled',
  }

  #Create a user definition:
  icinga2::object::user { 'nick':
    display_name => 'Nick',
    email => 'nick@usermail.local',
    period => '24x7',
    enable_notifications => 'true',
    groups => [ 'admins' ],
    states => [ 'OK', 'Warning', 'Critical', 'Unknown', 'Up', 'Down' ],
    types => [ 'Problem', 'Recovery', 'Acknowledgement', 'Custom', 'DowntimeStart', 'DowntimeEnd', 'DowntimeRemoved', 'FlappingStart', 'FlappingEnd' ],
    target_dir => '/etc/icinga2/objects/users',
  }

  #Create an admins user group:
  icinga2::object::usergroup { 'admins':
    display_name => 'admins',
    target_dir => '/etc/icinga2/objects/usergroups',
  }

  #Create a postgres_servers hostgroup:
  icinga2::object::hostgroup { 'postgres_servers':
    display_name => 'Postgres servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an IMAP servers hostgroup:
  icinga2::object::hostgroup { 'imap_servers':
    display_name => 'IMAP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an HTTP servers hostgroup:
  icinga2::object::hostgroup { 'http_servers':
    display_name => 'HTTP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an SSH servers hostgroup:
  icinga2::object::hostgroup { 'ssh_servers':
    display_name => 'SSH servers',
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

  #Dependency object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/28
  icinga2::object::dependency { "usermail to icinga2mail":
    object_name => "usermail_dep_on_icinga2mail",
    parent_host_name => 'icinga2mail.local',
    child_host_name => 'usermail.local',
    target_dir => '/etc/icinga2/objects/dependencies',
    target_file_name => "usermail_to_icinga2mail.conf",
  }

  #Apply_dependency object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/28
  icinga2::object::apply_dependency { 'usermail_dep_on_icinga2mail':
    parent_host_name => 'icinga2mail.local',
    assign_where => 'match("^usermail*", host.name)',
  }

  #Apply_dependency object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/28
  icinga2::object::apply_dependency { 'imap_dep_on_smtp':
    parent_service_name => 'check_ssh',
    object_type => 'Service',
    assign_where => 'match("^check_smtp*", service.name)',
  }

  #Create a web services servicegroup:
  icinga2::object::servicegroup { 'web_services':
    display_name => 'web services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a database services servicegroup:
  icinga2::object::servicegroup { 'database_services':
    display_name => 'database services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }
  
  #Create an email services servicegroup:
  icinga2::object::servicegroup { 'email_services':
    display_name => 'email services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a machine health services servicegroup:
  icinga2::object::servicegroup { 'machine_health':
    display_name => 'machine health',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create an apply that checks SSH:
  icinga2::object::apply_service_to_host { 'check_ssh':
    display_name => 'SSH',
    check_command => 'ssh',
    vars => {
      service_type => 'production',
    },
    assign_where => '"ssh_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks SMTP:
  icinga2::object::apply_service_to_host { 'check_smtp':
    display_name => 'SMTP',
    check_command => 'smtp',
    vars => {
      service_type => 'production',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks load average:
  icinga2::object::apply_service_to_host { 'load_average':
    display_name => 'Load average',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
      nrpe_command => 'check_mysql_service',
    },
    assign_where => '"mysql_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create a notificationcommand to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/32
  icinga2::object::notificationcommand { 'mail-service-notification-2':
    command   => ['"/icinga2/scripts/mail-notification.sh"'],
    cmd_path  => 'SysconfDir',
  }

  #Create an eventcommand to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/33
  icinga2::object::eventcommand { 'restart-httpd-event':
    command => [ '"/opt/bin/restart-httpd.sh"' ]
  }
  
  #Create a timeperiod object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/37
  icinga2::object::timeperiod { 'bra-office-hrs':
    timeperiod_display_name => 'Brazilian WorkTime Hours',
    timeperiod_ranges       => {
      'monday'    => '12:00-21:00',
      'tuesday'   => '12:00-21:00',
      'wednesday' => '12:00-21:00',
      'thursday'  => '12:00-21:00',
      'friday'    => '12:00-21:00'
    }
  }

  #Install Postfix so we can monitor SMTP services and send out email alerts:
  class { '::postfix::server':
    inet_interfaces => 'all', #Listen on all interfaces
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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

#An Ubuntu 12.04 Icinga2 server node
node 'preciseicinga2server.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': } ->

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  } ->

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
    grant => 'all',
  } ->

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => postgresql_password('icingaweb2', 'password'),
    grant => 'all',
  } ->

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    db_user        => 'icinga2',
    db_name        => 'icinga2_data',
    db_password    => 'password',
    db_host        => '127.0.0.1',
    db_port        => '5432',
    server_install_nagios_plugins => false,
    install_mail_utils_package => true,
    server_enabled_features  => ['checker','notification', 'livestatus', 'syslog'],
    server_disabled_features => ['graphite', 'api'],
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

  #Postgres IDO connection object:
  icinga2::object::idopgsqlconnection { 'testing_postgres':
     host             => '127.0.0.1',
     port             => 5432,
     user             => 'icinga2',
     password         => 'password',
     database         => 'icinga2_data',
     target_file_name => 'ido-pgsql.conf',
     target_dir       => '/etc/icinga2/features-enabled',
     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

#  #MySQL IDO connection object
#  icinga2::object::idomysqlconnection { 'testing_mysql':
#     host             => '127.0.0.1',
#     port             => 3306,
#     user             => 'icinga2',
#     password         => 'password',
#     database         => 'icinga2_data',
#     target_file_name => 'ido-mysql.conf',
#     target_dir       => '/etc/icinga2/features-enabled',
#     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
#  }

  #Create a sysloglogger object:
  icinga2::object::sysloglogger { 'syslog-warning':
    severity => 'warning',
    target_dir => '/etc/icinga2/features-enabled',
  }

  #Create a user definition:
  icinga2::object::user { 'nick':
    display_name => 'Nick',
    email => 'nick@usermail.local',
    period => '24x7',
    enable_notifications => 'true',
    groups => [ 'admins' ],
    states => [ 'OK', 'Warning', 'Critical', 'Unknown', 'Up', 'Down' ],
    types => [ 'Problem', 'Recovery', 'Acknowledgement', 'Custom', 'DowntimeStart', 'DowntimeEnd', 'DowntimeRemoved', 'FlappingStart', 'FlappingEnd' ],
    target_dir => '/etc/icinga2/objects/users',
  }

  #Create an admins user group:
  icinga2::object::usergroup { 'admins':
    display_name => 'admins',
    target_dir => '/etc/icinga2/objects/usergroups',
  }

  #Create a postgres_servers hostgroup:
  icinga2::object::hostgroup { 'postgres_servers':
    display_name => 'Postgres servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an IMAP servers hostgroup:
  icinga2::object::hostgroup { 'imap_servers':
    display_name => 'IMAP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an HTTP servers hostgroup:
  icinga2::object::hostgroup { 'http_servers':
    display_name => 'HTTP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an SSH servers hostgroup:
  icinga2::object::hostgroup { 'ssh_servers':
    display_name => 'SSH servers',
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

  #Create a web services servicegroup:
  icinga2::object::servicegroup { 'web_services':
    display_name => 'web services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a database services servicegroup:
  icinga2::object::servicegroup { 'database_services':
    display_name => 'database services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }
  
  #Create an email services servicegroup:
  icinga2::object::servicegroup { 'email_services':
    display_name => 'email services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a machine health services servicegroup:
  icinga2::object::servicegroup { 'machine_health':
    display_name => 'machine health',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create an apply that checks SSH:
  icinga2::object::apply_service_to_host { 'check_ssh':
    display_name => 'SSH',
    check_command => 'ssh',
    vars => {
      service_type => 'production',
    },
    assign_where => '"ssh_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks SMTP:
  icinga2::object::apply_service_to_host { 'check_smtp':
    display_name => 'SMTP',
    check_command => 'smtp',
    vars => {
      service_type => 'production',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks load average:
  icinga2::object::apply_service_to_host { 'load_average':
    display_name => 'Load average',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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

#CentOS 6 Icinga 2 server node
node 'centos6icinga2server.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': } ->

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  } ->

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
    grant => 'all',
  } ->

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => postgresql_password('icingaweb2', 'password'),
    grant => 'all',
  } ->

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    db_user        => 'icinga2',
    db_name        => 'icinga2_data',
    db_password    => 'password',
    db_host        => '127.0.0.1',
    db_port        => '5432',
    server_install_nagios_plugins => false,
    install_mail_utils_package => true,
    server_enabled_features  => ['checker','notification', 'livestatus', 'syslog'],
    server_disabled_features => ['graphite', 'api'],
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

  #Postgres IDO connection object:
  icinga2::object::idopgsqlconnection { 'testing_postgres':
     host             => '127.0.0.1',
     port             => 5432,
     user             => 'icinga2',
     password         => 'password',
     database         => 'icinga2_data',
     target_file_name => 'ido-pgsql.conf',
     target_dir       => '/etc/icinga2/features-enabled',
     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

#  #MySQL IDO connection object
#  icinga2::object::idomysqlconnection { 'testing_mysql':
#     host             => '127.0.0.1',
#     port             => 3306,
#     user             => 'icinga2',
#     password         => 'password',
#     database         => 'icinga2_data',
#     target_file_name => 'ido-mysql.conf',
#     target_dir       => '/etc/icinga2/features-enabled',
#     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
#  }

  #Create a sysloglogger object:
  icinga2::object::sysloglogger { 'syslog-warning':
    severity => 'warning',
    target_dir => '/etc/icinga2/features-enabled',
  }

  #Create a user definition:
  icinga2::object::user { 'nick':
    display_name => 'Nick',
    email => 'nick@usermail.local',
    period => '24x7',
    enable_notifications => 'true',
    groups => [ 'admins' ],
    states => [ 'OK', 'Warning', 'Critical', 'Unknown', 'Up', 'Down' ],
    types => [ 'Problem', 'Recovery', 'Acknowledgement', 'Custom', 'DowntimeStart', 'DowntimeEnd', 'DowntimeRemoved', 'FlappingStart', 'FlappingEnd' ],
    target_dir => '/etc/icinga2/objects/users',
  }

  #Create an admins user group:
  icinga2::object::usergroup { 'admins':
    display_name => 'admins',
    target_dir => '/etc/icinga2/objects/usergroups',
  }

  #Create a postgres_servers hostgroup:
  icinga2::object::hostgroup { 'postgres_servers':
    display_name => 'Postgres servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an IMAP servers hostgroup:
  icinga2::object::hostgroup { 'imap_servers':
    display_name => 'IMAP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an HTTP servers hostgroup:
  icinga2::object::hostgroup { 'http_servers':
    display_name => 'HTTP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an SSH servers hostgroup:
  icinga2::object::hostgroup { 'ssh_servers':
    display_name => 'SSH servers',
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

  #Create a web services servicegroup:
  icinga2::object::servicegroup { 'web_services':
    display_name => 'web services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a database services servicegroup:
  icinga2::object::servicegroup { 'database_services':
    display_name => 'database services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }
  
  #Create an email services servicegroup:
  icinga2::object::servicegroup { 'email_services':
    display_name => 'email services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a machine health services servicegroup:
  icinga2::object::servicegroup { 'machine_health':
    display_name => 'machine health',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create an apply that checks SSH:
  icinga2::object::apply_service_to_host { 'check_ssh':
    display_name => 'SSH',
    check_command => 'ssh',
    vars => {
      service_type => 'production',
    },
    assign_where => '"ssh_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks SMTP:
  icinga2::object::apply_service_to_host { 'check_smtp':
    display_name => 'SMTP',
    check_command => 'smtp',
    vars => {
      service_type => 'production',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks load average:
  icinga2::object::apply_service_to_host { 'load_average':
    display_name => 'Load average',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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

#A CentOS 7 Icinga 2 server node
node 'centos7icinga2server.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': } ->

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  } ->

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
    grant => 'all',
  } ->

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => postgresql_password('icingaweb2', 'password'),
    grant => 'all',
  } ->

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    db_user        => 'icinga2',
    db_name        => 'icinga2_data',
    db_password    => 'password',
    db_host        => '127.0.0.1',
    db_port        => '5432',
    server_install_nagios_plugins => false,
    install_mail_utils_package => true,
    server_enabled_features  => ['checker','notification', 'livestatus', 'syslog'],
    server_disabled_features => ['graphite', 'api'],
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

  #Postgres IDO connection object:
  icinga2::object::idopgsqlconnection { 'testing_postgres':
     host             => '127.0.0.1',
     port             => 5432,
     user             => 'icinga2',
     password         => 'password',
     database         => 'icinga2_data',
     target_file_name => 'ido-pgsql.conf',
     target_dir       => '/etc/icinga2/features-enabled',
     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

#  #MySQL IDO connection object
#  icinga2::object::idomysqlconnection { 'testing_mysql':
#     host             => '127.0.0.1',
#     port             => 3306,
#     user             => 'icinga2',
#     password         => 'password',
#     database         => 'icinga2_data',
#     target_file_name => 'ido-mysql.conf',
#     target_dir       => '/etc/icinga2/features-enabled',
#     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
#  }

  #Create a sysloglogger object:
  icinga2::object::sysloglogger { 'syslog-warning':
    severity => 'warning',
    target_dir => '/etc/icinga2/features-enabled',
  }

  #Create a user definition:
  icinga2::object::user { 'nick':
    display_name => 'Nick',
    email => 'nick@usermail.local',
    period => '24x7',
    enable_notifications => 'true',
    groups => [ 'admins' ],
    states => [ 'OK', 'Warning', 'Critical', 'Unknown', 'Up', 'Down' ],
    types => [ 'Problem', 'Recovery', 'Acknowledgement', 'Custom', 'DowntimeStart', 'DowntimeEnd', 'DowntimeRemoved', 'FlappingStart', 'FlappingEnd' ],
    target_dir => '/etc/icinga2/objects/users',
  }

  #Create an admins user group:
  icinga2::object::usergroup { 'admins':
    display_name => 'admins',
    target_dir => '/etc/icinga2/objects/usergroups',
  }

  #Create a postgres_servers hostgroup:
  icinga2::object::hostgroup { 'postgres_servers':
    display_name => 'Postgres servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an IMAP servers hostgroup:
  icinga2::object::hostgroup { 'imap_servers':
    display_name => 'IMAP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an HTTP servers hostgroup:
  icinga2::object::hostgroup { 'http_servers':
    display_name => 'HTTP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an SSH servers hostgroup:
  icinga2::object::hostgroup { 'ssh_servers':
    display_name => 'SSH servers',
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

  #Create a web services servicegroup:
  icinga2::object::servicegroup { 'web_services':
    display_name => 'web services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a database services servicegroup:
  icinga2::object::servicegroup { 'database_services':
    display_name => 'database services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }
  
  #Create an email services servicegroup:
  icinga2::object::servicegroup { 'email_services':
    display_name => 'email services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a machine health services servicegroup:
  icinga2::object::servicegroup { 'machine_health':
    display_name => 'machine health',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create an apply that checks SSH:
  icinga2::object::apply_service_to_host { 'check_ssh':
    display_name => 'SSH',
    check_command => 'ssh',
    vars => {
      service_type => 'production',
    },
    assign_where => '"ssh_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks SMTP:
  icinga2::object::apply_service_to_host { 'check_smtp':
    display_name => 'SMTP',
    check_command => 'smtp',
    vars => {
      service_type => 'production',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks load average:
  icinga2::object::apply_service_to_host { 'load_average':
    display_name => 'Load average',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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

#A Debian 7 Icinga2 server node
node 'debian7icinga2server.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postgres for use as a database with Icinga 2...
  class { 'postgresql::server': } ->

  #...and install MySQL as well:
  class { '::mysql::server':
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  } ->

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    password => postgresql_password('icinga2', 'password'),
    grant => 'all',
  } ->

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => postgresql_password('icingaweb2', 'password'),
    grant => 'all',
  } ->

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  } ->

  #Install Icinga 2:
  class { 'icinga2::server': 
    server_db_type => 'pgsql',
    db_user        => 'icinga2',
    db_name        => 'icinga2_data',
    db_password    => 'password',
    db_host        => '127.0.0.1',
    db_port        => '5432',
    use_debmon_repo => true,
    server_install_nagios_plugins => false,
    install_mail_utils_package => true,
    server_enabled_features  => ['checker','notification', 'livestatus', 'syslog'],
    server_disabled_features => ['graphite', 'api'],
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

  #Postgres IDO connection object:
  icinga2::object::idopgsqlconnection { 'testing_postgres':
     host             => '127.0.0.1',
     port             => 5432,
     user             => 'icinga2',
     password         => 'password',
     database         => 'icinga2_data',
     target_file_name => 'ido-pgsql.conf',
     target_dir       => '/etc/icinga2/features-enabled',
     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

#  #MySQL IDO connection object
#  icinga2::object::idomysqlconnection { 'testing_mysql':
#     host             => '127.0.0.1',
#     port             => 3306,
#     user             => 'icinga2',
#     password         => 'password',
#     database         => 'icinga2_data',
#     target_file_name => 'ido-mysql.conf',
#     target_dir       => '/etc/icinga2/features-enabled',
#     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
#  }

  #Create a sysloglogger object:
  icinga2::object::sysloglogger { 'syslog-warning':
    severity => 'warning',
    target_dir => '/etc/icinga2/features-enabled',
  }

  #Create a user definition:
  icinga2::object::user { 'nick':
    display_name => 'Nick',
    email => 'nick@usermail.local',
    period => '24x7',
    enable_notifications => 'true',
    groups => [ 'admins' ],
    states => [ 'OK', 'Warning', 'Critical', 'Unknown', 'Up', 'Down' ],
    types => [ 'Problem', 'Recovery', 'Acknowledgement', 'Custom', 'DowntimeStart', 'DowntimeEnd', 'DowntimeRemoved', 'FlappingStart', 'FlappingEnd' ],
    target_dir => '/etc/icinga2/objects/users',
  }

  #Create an admins user group:
  icinga2::object::usergroup { 'admins':
    display_name => 'admins',
    target_dir => '/etc/icinga2/objects/usergroups',
  }

  #Create a postgres_servers hostgroup:
  icinga2::object::hostgroup { 'postgres_servers':
    display_name => 'Postgres servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an IMAP servers hostgroup:
  icinga2::object::hostgroup { 'imap_servers':
    display_name => 'IMAP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an HTTP servers hostgroup:
  icinga2::object::hostgroup { 'http_servers':
    display_name => 'HTTP servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Create an SSH servers hostgroup:
  icinga2::object::hostgroup { 'ssh_servers':
    display_name => 'SSH servers',
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

  #Create a web services servicegroup:
  icinga2::object::servicegroup { 'web_services':
    display_name => 'web services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a database services servicegroup:
  icinga2::object::servicegroup { 'database_services':
    display_name => 'database services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }
  
  #Create an email services servicegroup:
  icinga2::object::servicegroup { 'email_services':
    display_name => 'email services',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create a machine health services servicegroup:
  icinga2::object::servicegroup { 'machine_health':
    display_name => 'machine health',
    target_dir => '/etc/icinga2/objects/servicegroups',
  }

  #Create an apply that checks SSH:
  icinga2::object::apply_service_to_host { 'check_ssh':
    display_name => 'SSH',
    check_command => 'ssh',
    vars => {
      service_type => 'production',
    },
    assign_where => '"ssh_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks SMTP:
  icinga2::object::apply_service_to_host { 'check_smtp':
    display_name => 'SMTP',
    check_command => 'smtp',
    vars => {
      service_type => 'production',
    },
    assign_where => '"linux_servers" in host.groups',
    ignore_where => 'host.name == "localhost"',
    target_dir => '/etc/icinga2/objects/applys'
  }

  #Create an apply that checks load average:
  icinga2::object::apply_service_to_host { 'load_average':
    display_name => 'Load average',
    check_command => 'nrpe',
    vars => {
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
      service_type => 'production',
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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

#An Ubuntu 14.04 Icinga 2 client node
node 'trustyicinga2client.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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
    groups => ['linux_servers', 'mysql_servers', 'postgres_servers', 'clients', 'smtp_servers', 'ssh_servers', 'http_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

#An Ubuntu 12.04 Icinga 2 client node
node 'preciseicinga2client.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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
    groups => ['linux_servers', 'mysql_servers', 'postgres_servers', 'clients', 'smtp_servers', 'ssh_servers', 'http_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

#A CentOS 6 Icinga 2 client node
node 'centos6icinga2client.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
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
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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
    groups => ['linux_servers', 'mysql_servers', 'postgres_servers', 'clients', 'smtp_servers', 'ssh_servers', 'http_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

#A CentOS 7 Icinga 2 client node
node 'centos7icinga2client.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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
    groups => ['linux_servers', 'mysql_servers', 'postgres_servers', 'clients', 'smtp_servers', 'ssh_servers', 'http_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

#A Debian 7 Icinga 2 client node
node 'debian7icinga2client.local' {

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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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
    groups => ['linux_servers', 'mysql_servers', 'postgres_servers', 'clients', 'smtp_servers', 'ssh_servers', 'http_servers'],
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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #Install Java...
  package { 'openjdk-7-jre-headless':
    ensure => installed,
  }

  #...so that we can install Elasticsearch...
  class { 'elasticsearch':
    java_install => false,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb',
    config => { 'cluster.name'             => 'logstash',
                'network.host'             => $ipaddress_eth1,
                'index.number_of_replicas' => '1',
                'index.number_of_shards'   => '4',
    },
  }

  #...and set up an Elasticsearch instance:
  elasticsearch::instance { $fqdn:
    config => { 'node.name' => $fqdn }
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
    extra_main_parameters => {
      'home_mailbox' => 'Maildir/',
      'mailbox_command' => '',
      'disable_dns_lookups' => 'yes' #Don't do DNS lookups for MX records since we're just using /etc/hosts for all host lookups
    }  
  }

  class { 'icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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
    groups => ['linux_servers', 'mysql_servers', 'postgres_servers', 'clients', 'smtp_servers', 'ssh_servers', 'http_servers'],
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
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'icinga2logging.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

  #Install Java...
  package { 'openjdk-7-jre-headless':
    ensure => installed,
  }

  #...so that we can install Elasticsearch...
  class { 'elasticsearch':
    java_install => false,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb',
    config => { 'cluster.name'             => 'logstash',
                'network.host'             => $ipaddress_eth1,
                'index.number_of_replicas' => '1',
                'index.number_of_shards'   => '4',
    },
  }

  #...and set up an Elasticsearch instance:
  elasticsearch::instance { $fqdn:
    config => { 'node.name' => $fqdn }
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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
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
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
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
    groups => ["linux_servers", 'mysql_servers', 'postgres_servers', 'clients', 'smtp_servers', 'ssh_servers', 'http_servers', 'imap_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

node 'icinga2logging.local' {

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
    mynetworks => '127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128 10.0.1.0/24',
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
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
    nrpe_listen_port => 5666,
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
    groups => ["linux_servers", 'mysql_servers', 'postgres_servers', 'clients', 'smtp_servers', 'ssh_servers', 'http_servers', 'imap_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

  #Install Logstash:  
  class { 'logstash':
    java_install => true,
    java_package => 'openjdk-7-jre-headless',
    package_url => 'https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb',
    install_contrib => true,
    contrib_package_url => 'https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash-contrib_1.4.2-1-efd53ef_all.deb',
  }

  logstash::configfile { 'logstash_monolithic':
    source => 'puppet:///logstash/configs/logstash.conf',
    order   => 10
  }

  #Install Elasticsearch...
  class { 'elasticsearch':
    java_install => false,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb',
    config => { 'cluster.name'             => 'logstash',
                'network.host'             => $ipaddress_eth1,
                'index.number_of_replicas' => '1',
                'index.number_of_shards'   => '4',
    },
  }

  #...and some plugins:
  elasticsearch::instance { $fqdn:
    config => { 'node.name' => $fqdn }
  }

  elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head',
    instances  => $fqdn,
  }

  elasticsearch::plugin{'karmi/elasticsearch-paramedic':
    module_dir => 'paramedic',
    instances  => $fqdn,
  }

  elasticsearch::plugin{'lmenezes/elasticsearch-kopf':
    module_dir => 'kopf',
    instances  => $fqdn,
  }

  file {'/sites/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  file {'/sites/apps/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  #A non-SSL virtual host for Kibana:
  ::apache::vhost { 'kibana.icinga2logging.local_non-ssl':
    port            => 80,
    docroot         => '/sites/apps/kibana3',
    servername      => "kibana.${fqdn}",
    access_log => true,
    access_log_syslog=> 'syslog:local1',
    error_log => true,
    error_log_syslog=> 'syslog:local1',
    custom_fragment => '
      #Disable multiviews since they can have unpredictable results
      <Directory "/sites/apps/kibana3">
        AllowOverride All
        Require all granted
        Options -Multiviews
      </Directory>
    ',
  }

  #Create a folder where the SSL certificate and key will live:
  file {'/etc/apache2/ssl': 
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '600',
  }

}