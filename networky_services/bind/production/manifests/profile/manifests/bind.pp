class profile::bind { }

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
   
  ::bind::server::conf { '/etc/named.conf':
    acls => {
      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ],
      'local'   => [ '127.0.0.1' ],
      '10net'   => [ '10.0.0.0/24', '10.0.1.0/24', '10.1.1.0/24', '10.1.0.0/24'],
    },
    directory => '/var/named/',
    listen_on_addr    => [ '127.0.0.1' ],
    listen_on_v6_addr => [ '::1' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localhost', 'local' ],
    recursion         => 'no',
    allow_recursion   => [ 'localhost', 'local', '10net'],
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
    }
  }

  ::bind::server::file { [ 'zone1.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///bind/zone_files/',
  }

  ::bind::server::file { [ 'zone2.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///bind/zone_files/',
  }

  ::bind::server::file { [ 'zone3.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///bind/zone_files/',
  }

  ::bind::server::file { [ 'zone4.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///bind/zone_files/',
  }

  ::bind::server::file { [ 'zone5.local.zone' ]:
    zonedir => '/var/named/data',
    source_base => 'puppet:///bind/zone_files/',
  }

}