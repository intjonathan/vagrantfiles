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

#Puppet master definition
node 'graphitemaster.local' {

  #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  class {'puppetdb::master::config':
    #Don't restart the puppetmaster process; we're loading the Puppet master's Ruby code via
    #Apache and Passenger, so we don't want the Webrick daemon started:
    restart_puppet => false,
  }

  #Apache modules for PuppetBoard:
  class { 'apache': 
    purge_configs => 'false'
  }
  
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }
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

#Ubuntu Graphite server
node 'graphite1.local' {

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
    log_remote     => false,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  #Install Apache so we have something that can serve the Graphite web UI and HTTP API.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  include apache

  #Install Postgres:
  class { 'postgresql::server': }

  #Create a Postgres DB for Graphite
  postgresql::server::db { 'graphite_data':
    user     => 'graphite',
    password => postgresql_password('graphite', 'password'),
  }
  
  #Install MySQL:
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }
  
  #Create a MySQL DB for Graphite  
  mysql::db { 'graphite_data':
    user     => 'graphite',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Graphite stuff:
  class{'graphite::server':
    #This is a salted hash for 'password' with '54321' as the salt; PBKDF2 with SHA256 is the algorithm:
    django_admin_password => 'pbkdf2_sha256$12000$54321$RAkQjc8YAPaOl8OL21l7R2K/cgLeBcJTPNQss1oJpVk=',
  }

}

#CentOS Graphite server
node 'graphite2.local' {

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
    log_remote     => false,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we have something that can serve the Graphite web UI and HTTP API.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  include apache

  #Install Postgres:
  class { 'postgresql::server': }

  #Create a Postgres DB for Graphite
  postgresql::server::db { 'graphite_data':
    user     => 'graphite',
    password => postgresql_password('graphite', 'password'),
  }
  
  #Install MySQL:
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }
  
  #Create a MySQL DB for Graphite  
  mysql::db { 'graphite_data':
    user     => 'graphite',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #Graphite stuff:
  class{'graphite::server':
    #This is a salted hash for 'password' with '54321' as the salt; PBKDF2 with SHA256 is the algorithm:
    django_admin_password => 'pbkdf2_sha256$12000$54321$RAkQjc8YAPaOl8OL21l7R2K/cgLeBcJTPNQss1oJpVk=',
  }

}

#Ubuntu Graphite node
node 'node1.local' {

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
    log_remote     => false,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  #Install Apache so we test collectd's Apache metrics gathering.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  include apache

  #Install MySQL to test collectd's MySQL metrics gathering.
  #This module is the Puppet Labs MySQL module: https://github.com/puppetlabs/puppetlabs-mysql
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    users => {
      #Create a collectd DB user:
      'collectd@localhost' => {
          ensure                   => 'present',
          max_connections_per_hour => '0',
          max_queries_per_hour     => '0',
          max_updates_per_hour     => '0',
          max_user_connections     => '0',
          password_hash            => mysql_password('password'),
        }
    },
    grants => {
      #Let the collectd DB user read
      'collectd@localhost/*.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['USAGE'],
        table      => '*.*',
        user       => 'collectd@localhost',
      },
    }
  }

  include collectd
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'graphitemaster.local',
  }

}

#Ubuntu Graphite node
node 'node2.local' {

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
    log_remote     => false,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we test collectd's Apache metrics gathering.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  include apache

  #Install MySQL to test collectd's MySQL metrics gathering.
  #This module is the Puppet Labs MySQL module: https://github.com/puppetlabs/puppetlabs-mysql
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    users => {
      #Create a collectd DB user:
      'collectd@localhost' => {
          ensure                   => 'present',
          max_connections_per_hour => '0',
          max_queries_per_hour     => '0',
          max_updates_per_hour     => '0',
          max_user_connections     => '0',
          password_hash            => mysql_password('password'),
        }
    },
    grants => {
      #Let the collectd DB user read
      'collectd@localhost/*.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['USAGE'],
        table      => '*.*',
        user       => 'collectd@localhost',
      },
    }
  }

  include collectd
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'graphitemaster.local',
  }

}

#CentOS Graphite node
node 'node3.local' {

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
    log_remote     => false,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we test collectd's Apache metrics gathering.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  include apache

  #Install MySQL to test collectd's MySQL metrics gathering.
  #This module is the Puppet Labs MySQL module: https://github.com/puppetlabs/puppetlabs-mysql
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    users => {
      #Create a collectd DB user:
      'collectd@localhost' => {
          ensure                   => 'present',
          max_connections_per_hour => '0',
          max_queries_per_hour     => '0',
          max_updates_per_hour     => '0',
          max_user_connections     => '0',
          password_hash            => mysql_password('password'),
        }
    },
    grants => {
      #Let the collectd DB user read
      'collectd@localhost/*.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['USAGE'],
        table      => '*.*',
        user       => 'collectd@localhost',
      },
    }
  }

}

#CentOS Graphite node
node 'node4.local' {

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
    log_remote     => false,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }
  
    #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we test collectd's Apache metrics gathering.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  include apache

  #Install MySQL to test collectd's MySQL metrics gathering.
  #This module is the Puppet Labs MySQL module: https://github.com/puppetlabs/puppetlabs-mysql
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    users => {
      #Create a collectd DB user:
      'collectd@localhost' => {
          ensure                   => 'present',
          max_connections_per_hour => '0',
          max_queries_per_hour     => '0',
          max_updates_per_hour     => '0',
          max_user_connections     => '0',
          password_hash            => mysql_password('password'),
        }
    },
    grants => {
      #Let the collectd DB user read
      'collectd@localhost/*.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['USAGE'],
        table      => '*.*',
        user       => 'collectd@localhost',
      },
    }
  }

}

#Ubuntu Graphite node
node 'node5.local' {

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
    log_remote     => false,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }
  
    #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we test collectd's Apache metrics gathering.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  include apache

  #Install MySQL to test collectd's MySQL metrics gathering.
  #This module is the Puppet Labs MySQL module: https://github.com/puppetlabs/puppetlabs-mysql
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    users => {
      #Create a collectd DB user:
      'collectd@localhost' => {
          ensure                   => 'present',
          max_connections_per_hour => '0',
          max_queries_per_hour     => '0',
          max_updates_per_hour     => '0',
          max_user_connections     => '0',
          password_hash            => mysql_password('password'),
        }
    },
    grants => {
      #Let the collectd DB user read
      'collectd@localhost/*.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['USAGE'],
        table      => '*.*',
        user       => 'collectd@localhost',
      },
    }
  }

  include collectd
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'graphitemaster.local',
  }

}

#CentOS Graphite node
node 'node6.local' {

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
    log_remote     => false,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'graphitemaster.local',
    port           => '514',
  }
  
    #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Apache so we test collectd's Apache metrics gathering.
  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  include apache

  #Install MySQL to test collectd's MySQL metrics gathering.
  #This module is the Puppet Labs MySQL module: https://github.com/puppetlabs/puppetlabs-mysql
  class { '::mysql::server':
    root_password    => 'password',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } },
    users => {
      #Create a collectd DB user:
      'collectd@localhost' => {
          ensure                   => 'present',
          max_connections_per_hour => '0',
          max_queries_per_hour     => '0',
          max_updates_per_hour     => '0',
          max_user_connections     => '0',
          password_hash            => mysql_password('password'),
        }
    },
    grants => {
      #Let the collectd DB user read
      'collectd@localhost/*.*' => {
        ensure     => 'present',
        options    => ['GRANT'],
        privileges => ['USAGE'],
        table      => '*.*',
        user       => 'collectd@localhost',
      },
    }
  }

}