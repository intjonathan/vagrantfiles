#default node defition
node default {

}

#puppet master node definition
node 'openmanagemaster.local' {

  #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }

  include denyhosts

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
  class { 'ssh':
    server_options => {
      #Export host keys to PuppetDB:
      storeconfigs_enabled => true,
      options => {
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

node 'openmanage1.local' {

  include denyhosts

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    server_options => {
      #Export host keys to PuppetDB:
      storeconfigs_enabled => true,
      options => {
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

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openmanagemaster.local',
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

node 'openmanage2.local' {

  include denyhosts

  #This module is from: https://github.com/saz/puppet-ssh
  class { 'ssh':
    server_options => {
      #Export host keys to PuppetDB:
      storeconfigs_enabled => true,
      options => {
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

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'openmanagemaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

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
    recursion         => 'no',
    allow_recursion   => [ 'localhost', 'local', '10net'],
    #Include some other zone files for localhost and loopback zones:
    includes => ['/etc/named.rfc1912.zones', '/etc/named.root.key'],
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
