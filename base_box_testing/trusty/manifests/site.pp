#default node defition
node default {

}

#puppet master node definition
node 'trustypuppetmaster.local' {

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

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh
 
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::server':
    enable_tcp => true,
    enable_udp => true,
    port       => '514',
    server_dir => '/var/log/remote/',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

node 'trustypuppetagent.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'trustypuppetmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  #BIND module is from: https://github.com/thias/puppet-bind
  include bind
  bind::server::conf { '/etc/bind/named.conf':
    acls => {
      'rfc1918' => [ '10/8', '172.16/12', '192.168/16' ],
      'local'   => [ '127.0.0.1' ],
      '10net'   => [ '10.0.0.0/24', '10.0.1.0/24', '10.1.1.0/24', '10.1.0.0/24'],
    },
    directory => '/etc/bind/',
    listen_on_addr    => [ '127.0.0.1' ],
    listen_on_v6_addr => [ '::1' ],
    forwarders        => [ '8.8.8.8', '8.8.4.4' ],
    allow_query       => [ 'localhost', 'local' ],
    recursion         => 'no',
    allow_recursion   => [ 'localhost', 'local', '10net'],
    #Include some other zone files for localhost and loopback zones:
    includes => ['/etc/bind/named.conf.local', '/etc/bind/named.conf.default-zones'],
    zones => {
      #root hints zone
      '.' => [
        'type hint',
        'file "/etc/bind/db.root"',
      ], 
      'zone1.local' => [
      'type master',
      'file "zone1.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone2.local' => [
      'type master',
      'file "zone2.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone3.local' => [
      'type master',
      'file "zone3.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone4.local' => [
      'type master',
      'file "zone4.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    'zone5.local' => [
      'type master',
      'file "zone5.local"',
      'allow-query { any; }',
      'allow-transfer { 10net; }',
      'allow-update { local; }',
      ],
    }
  }

}