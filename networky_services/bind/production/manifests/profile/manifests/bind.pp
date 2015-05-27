class profile::bind {

  ###############################
  # Icinga 2 host exporting
  ###############################

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    #hieravaluereplace
    groups => ['linux_servers', 'icinga2_clients', 'ssh_servers', 'dns_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}

class profile::bind::master { 

  ###############################
  # BIND installation/setup
  ###############################

  #BIND module is from: https://github.com/thias/puppet-bind
   class { '::bind':
    service_reload => true,
    #Use a custom restart command
    #The command below runs named-checkconf and only runs 'service named restart' if 'named-checkconf' succeeds
    service_restart_command => '/sbin/named-checkconf -z /etc/named.conf && /sbin/service named restart'
  }
   
  #Configure BIND:
  ::bind::server::conf { '/etc/named.conf':
    acls => {
      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ],
      'local'   => [ '127.0.0.1' ],
      '10net'   => [ '10.0.0.0/24', '10.0.1.0/24', '10.1.1.0/24', '10.1.0.0/24'],
    },
    #Where BIND will keep its data:
    directory => '/var/named/',
    listen_on_addr    => [ '127.0.0.1' ],
    listen_on_v6_addr => [ '::1' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localhost', 'local', '10net' ],
    recursion         => 'no',
    allow_recursion   => [ 'localhost', 'local', '10net'],
    #Enable logging to /var/log/named/named.log
    #See http://www.zytrax.com/books/dns/ch7/logging.html for more info on BIND logging options.
    logging => {
      'categories' => {
        'default'      => 'main_log',
        'lame-servers' => 'null',
        'queries'      => 'query_log'
      },
      'channels' => {
        #This channel gets all logs except query logs:
        'main_log' => {
          channel_type   => 'file',
          #This parameter only applies if the 'channel_type' is set to 'syslog':
          facility       => 'daemon',
          #'file_location', 'versions' and 'size' only get applied if the 'channel_type' is set to 'file':
          file_location  => '/var/log/named/named.log',
          #Keep 3 older rotated logs
          versions       => '3',
          #Rotate named.log when it reaches 5MB in size:
          size           => '5m',
          severity       => 'info',
          print-time     => 'yes',
          print-severity => 'yes',
          print-category => 'yes'
        },
        #This channel gets query logs:
        'query_log' => {
          channel_type   => 'file',
          #This parameter only applies if the 'channel_type' is set to 'syslog':
          facility       => 'daemon',
          #'file_location', 'versions' and 'size' only get applied if the 'channel_type' is set to 'file':
          file_location  => '/var/log/named/named_query.log',
          #Keep 3 older rotated logs
          versions       => '3',
          #Rotate named.log when it reaches 5MB in size:
          size           => '5m',
          severity       => 'info',
          print-time     => 'yes',
          print-severity => 'yes',
          print-category => 'yes'
        },
      },
    },
    #Enable a statistics channel so collectd can gather DNS metrics:
    statistics_channels    => {
      'channel-1' => {
        listen_address => '*',
        listen_port    => '9053',
        allow          => ['localhost', '10net'],
      },
    },
    #Specify a managed keys directory; BIND needs this specified in /etc/named.conf or it 
    #won't be able to write to it; unfortunately, the module has the value default to 'undef'
    #and won't print it in named.conf if nothing is specified
    managed_keys_directory => '/var/named/dynamic',
    #Include some other zone files for localhost and loopback zones:
    includes => ['/etc/named.rfc1912.zones', '/etc/named.root.key'],
    zones => {
      #root hints zone
      '.' => [
        'type hint',
        'file "named.ca"',
      ], 
      'zone1.local' => [
      'type master',
      'file "data/zone1.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone2.local' => [
      'type master',
      'file "data/zone2.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone3.local' => [
      'type master',
      'file "data/zone3.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone4.local' => [
      'type master',
      'file "data/zone4.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone5.local' => [
      'type master',
      'file "data/zone5.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    '10.in-addr.arpa' => [
      'type master',
      'file "/var/named/data/db.10.zone1.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    '12.in-addr.arpa' => [
      'type master',
      'file "/var/named/data/db.12.zone2.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    '13.in-addr.arpa' => [
      'type master',
      'file "/var/named/data/db.13.zone3.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    '14.in-addr.arpa' => [
      'type master',
      'file "/var/named/data/db.14.zone4.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    '15.in-addr.arpa' => [
      'type master',
      'file "/var/named/data/db.15.zone5.local.zone"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    }
  }

  #Forward zones:
  ::bind::server::file { [ 'zone1.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ::bind::server::file { [ 'zone2.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ::bind::server::file { [ 'zone3.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ::bind::server::file { [ 'zone4.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ::bind::server::file { [ 'zone5.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }
  
  #Reverse zones:
  ::bind::server::file { [ 'db.10.zone1.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ::bind::server::file { [ 'db.12.zone2.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ::bind::server::file { [ 'db.13.zone3.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ::bind::server::file { [ 'db.14.zone4.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ::bind::server::file { [ 'db.15.zone5.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///files/bind/zone_files/',
  }

  ###########################################
  # Heka setup for DNS query log parsing
  ###########################################
  
  #Take in the query logs from the file they get written to by the query_log channel
  #defined above:
  ::heka::plugin { 'bind_query_logs':
    type => 'LogstreamerInput',
    settings => {
      'log_directory' => '"/var/log/named"',
      'file_match' => "'named_query.log'",
      'decoder' => '"bind_query_log_decoder"',
    },
  }

  #BIND query log decoder plugin:
  ::heka::plugin { 'bind_query_log_decoder':
    type => 'SandboxDecoder',
    settings => {
      'filename' => '"lua_decoders/bind_queryies.lua"',

    },
  }

  #Add a PayloadEncoder and LogOutput so that we can see the BIND query logs get sent to
  #Heka's standard output to make sure things are working. Adapted from:
  #https://hekad.readthedocs.org/en/latest/getting_started.html#simplest-heka-config
  #Keep this commented out so it's not used all the time. It's mostly only useful for
  #debugging:
  ::heka::plugin { 'bind_query_log_payload_encoder':
    type => 'PayloadEncoder',
    settings => {
      'append_newlines' => 'false',
    },
  }
  #Use the 'bind_query_log_stdout_output' PayloadEncoder we defined above:
  ::heka::plugin { 'bind_query_log_stdout_output':
    type => 'LogOutput',
    settings => {
      'message_matcher' => '"TRUE"',
      'encoder' => '"bind_query_log_payload_encoder"'
    },
  }

}