#default node defition
node default {

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

}

#Puppet master definition
node 'ansiblemaster.local' {

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

#Ubuntu Ansible node
node 'ansible1.local' {

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
    server         => 'saltmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#Ubuntu Ansible node
node 'ansible2.local' {

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
    server         => 'saltmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#CentOS Ansible node
node 'ansible3.local' {

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
    server         => 'saltmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#CentOS Ansible node
node 'ansible4.local' {

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
    server         => 'saltmaster.local',
    port           => '514',
  }
  
  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
}

#Ubuntu Ansible node
node 'ansible5.local' {

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
    server         => 'saltmaster.local',
    port           => '514',
  }
  
  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

#CentOS Ansible node
node 'ansible6.local' {

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
    server         => 'saltmaster.local',
    port           => '514',
  }
  
  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.node.org', '1.centos.pool.node.org', '2.centos.pool.node.org', '3.centos.pool.node.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
}