class profile::icinga2::server::objects {

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

  #Create a sysloglogger object:
  icinga2::object::sysloglogger { 'syslog-warning':
    severity => 'warning',
    target_dir => '/etc/icinga2/features-enabled',
  }

  #Create a compatlogger obect to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/54
  icinga2::object::compatlogger { 'daily-log':
    log_dir         => '/var/log/icinga2/compat',
    rotation_method => 'DAILY'
  }
  
  #Create a CheckResultReader object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/55
  icinga2::object::checkresultreader {'reader':
    spool_dir => '/data/check-results'
  }

  #Create a user definition:
  icinga2::object::user { 'nick':
    display_name => 'Nick',
    email => 'nick@dnsusermail.local',
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

  #Create a DNS servers hostgroup
  icinga2::object::hostgroup { 'dns_servers':
    display_name => 'DNS servers',
    target_dir => '/etc/icinga2/objects/hostgroups',
  }

  #Dependency object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/28
  icinga2::object::dependency { "dnsdnsusermail to dnsmailrelay":
    object_name => "dnsusermail_dep_on_dnsmailrelay",
    #hieravaluereplace
    parent_host_name => 'dnsmailrelay.local',
    child_host_name => 'dnsdnsusermail.local',
    target_dir => '/etc/icinga2/objects/dependencies',
    target_file_name => "dnsusermail_to_dnsmailrelay.conf",
  }

  #Apply_dependency object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/28
  icinga2::object::apply_dependency { 'dnsusermail_dep_on_dnsmailrelay':
    #hieravaluereplace
    parent_host_name => 'dnsmailrelay.local',
    assign_where => 'match("^dnsusermail*", host.name)',
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

  #Create an IcingaStatusWriter object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/62
  icinga2::object::icingastatuswriter { 'status':
    status_path       => '/cache/icinga2/status.json',
    update_interval   => '15s',
  }

  #Create a FileLogger object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/61
  icinga2::object::filelogger { 'debug-file':
    severity => 'debug',
    path     => '/var/log/icinga2/debug.log',
  }

  #Create a timeperiod object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/37
  icinga2::object::timeperiod { 'bra-office-hrs':
    timeperiod_display_name => 'Brazilian WorkTime Hours',
    ranges       => {
      'monday'    => '12:00-21:00',
      'tuesday'   => '12:00-21:00',
      'wednesday' => '12:00-21:00',
      'thursday'  => '12:00-21:00',
      'friday'    => '12:00-21:00'
    }
  }

  #Create an apply_notification_to_service object to test this PR: https://github.com/Icinga/puppet-icinga2/pull/44
  icinga2::object::apply_notification_to_service { 'pagerduty-service':
    assign_where => 'service.vars.enable_pagerduty == "true"',
    command      => 'notify-service-by-pagerduty',
    users        => [ 'pagerduty' ],
    states       => [ 'OK', 'Warning', 'Critical', 'Unknown' ],
    types        => [ 'Problem', 'Acknowledgement', 'Recovery', 'Custom' ],
    period       => '24x7',
  }

  #Create a LiveStatusListener object to test this PR: https://github.com/Icinga/puppet-icinga2/pull/48
  icinga2::object::livestatuslistener { 'livestatus-unix':
    socket_type => 'unix',
    socket_path => '/var/run/icinga2/cmd/livestatus'
  }

  #Create an ExternalCommandListener object to test this PR: https://github.com/Icinga/puppet-icinga2/pull/50
  icinga2::object::externalcommandlistener { 'external':
    command_path => '/var/run/icinga2/cmd/icinga2.cmd'
  }

  #Create a statusdatawriter object to test this PR: https://github.com/Icinga/puppet-icinga2/pull/49
  icinga2::object::statusdatawriter { 'status':
      status_path     => '/var/cache/icinga2/status.dat',
      objects_path    => '/var/cache/icinga2/objects.path',
      update_interval => 30s
  }

  #Create a scheduled downtime object to test this PR: https://github.com/Icinga/puppet-icinga2/pull/38
  icinga2::object::scheduleddowntime {'some-downtime':
    host_name    => 'dnsusermail.local',
    service_name => 'ping4',
    author       => 'icingaadmin',
    comment      => 'Some comment',
    fixed        => false,
    duration     => '30m',
    ranges       => { 'sunday' => '02:00-03:00' }
  }

  #Create an apply_notification_to_host object to test this PR: https://github.com/Icinga/puppet-icinga2/pull/43
  icinga2::object::apply_notification_to_host { 'pagerduty-host':
    assign_where => 'host.vars.enable_pagerduty == "true"',
    command      => 'notify-host-by-pagerduty',
    users        => [ 'pagerduty' ],
    states       => [ 'Up', 'Down' ],
    types        => [ 'Problem', 'Acknowledgement', 'Recovery', 'Custom' ],
    period       => '24x7',
  }
  
  #Create a PerfDataWriter object to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/47
  icinga2::object::perfdatawriter { 'pnp':
    host_perfdata_path      => '/var/spool/icinga2/perfdata/host-perfdata',
    service_perfdata_path   => '/var/spool/icinga2/perfdata/service-perfdata',
    host_format_template    => 'DATATYPE::HOSTPERFDATA\tTIMET::$icinga.timet$\tHOSTNAME::$host.name$\tHOSTPERFDATA::$host.perfdata$\tHOSTCHECKCOMMAND::$host.check_command$\tHOSTSTATE::$host.state$\tHOSTSTATETYPE::$host.state_type$',
    service_format_template => 'DATATYPE::SERVICEPERFDATA\tTIMET::$icinga.timet$\tHOSTNAME::$host.name$\tSERVICEDESC::$service.name$\tSERVICEPERFDATA::$service.perfdata$\tSERVICECHECKCOMMAND::$service.check_command$\tHOSTSTATE::$host.state$\tHOSTSTATETYPE::$host.state_type$\tSERVICESTATE::$service.state$\tSERVICESTATETYPE::$service.state_type$',
    rotation_interval       => '15s'
  }

  #Create an HTTP check command:
  icinga2::object::checkcommand { 'check_http':
    command => ['"/check_http"'],
    arguments     => {'"-H"'             => '"$http_vhost$"',
      '"-I"'          => '"$http_address$"',
      '"-u"'          => '"$http_uri$"',
      '"-p"'          => '"$http_port$"',
      '"-S"'          => {
        'set_if' => '"$http_ssl$"'
      },
      '"--sni"'       => {
        'set_if' => '"$http_sni$"'
      },
      '"-a"'          => {
        'value'       => '"$http_auth_pair$"',
        'description' => '"Username:password on sites with basic authentication"'
      },
      '"--no-body"'   => {
        'set_if' => '"$http_ignore_body$"'
      },
      '"-r"' => '"$http_expect_body_regex$"',
      '"-w"' => '"$http_warn_time$"',
      '"-c"' => '"$http_critical_time$"',
      '"-e"' => '"$http_expect$"'
    },
    vars => {
      'vars.http_address' => '"$address$"',
      'vars.http_ssl'     => 'false',
      'vars.http_sni'     => 'false'
    }
  }

  #Create a notification object to test this PR: https://github.com/Icinga/puppet-icinga2/pull/36
  icinga2::object::notification { 'dnsusermail-ping-notification':
    host_name => "dnsusermail.local",
    service_name => "ping4",
    command => "mail-service-notification",
    types => [ 'Problem', 'Recovery' ]
    }

  #Created a checkplugin object to test out this PR's feature of specifying content inline: https://github.com/Icinga/puppet-icinga2/pull/77:
  ::icinga2::checkplugin { 'check_diskstats':
    checkplugin_file_distribution_method => 'inline',
    checkplugin_source_inline            => 'command[check_disks]=/usr/lib64/nagios/plugins/check_disk -w 20 -c 10 -p /',
  }

}