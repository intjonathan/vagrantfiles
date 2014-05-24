#default node defition
node default {

}

#Puppet master node definition
node 'selinuxmaster.local' {

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
 
}

#Ubuntu ElasticSearch node
node 'selinux1.local' {

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
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }
  
  package { 'smartmontools':
    ensure => installed,
  }
}

#Ubuntu ElasticSearch node
node 'selinux2.local' {

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
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}

#Ubuntu ElasticSearch node
node 'selinux3.local' {

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
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}

#Ubuntu ElasticSearch node
node 'selinux4.local' {

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
    server         => 'selinuxmaster.local',
    port           => '514',
  }

  class { 'selinux':
    mode => 'permissive'
  }

  package { 'smartmontools':
    ensure => installed,
  }

}