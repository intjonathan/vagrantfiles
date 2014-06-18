#default node defition
node default {

}

#puppet master node definition
node 'riemannmaster.local' {

    #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config

  #Apache modules for PuppetBoard:
  class { 'apache': 
    purge_configs => 'true'
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

  class { 'fail2ban':
    log_level => '3',
  }

  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    ignoreip => ['127.0.0.1', '10.0.1.0/24'],
    logpath  => '/var/log/auth.log',
    maxretry => '10',
    bantime => '3600',
  }

  fail2ban::filter {'sshdtesting':
    daemon => 'sshd',
    failregex => '
      ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
      ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
      ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?(: (ruser .*|(\S+ ID \S+ \(serial \d+\) CA )?\S+ %(__md5hex)s(, client user ".*", client host >
      ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
      ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because listed in DenyUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not in any group\s*$
      ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because none of user\'s groups are listed in AllowGroups\s*$    
    ',
  }

  #Install Postfix locally so that Fail2Ban can send out emails
  class { '::postfix::server':
    inet_interfaces => 'localhost', #Only listen on localhost
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
  }

}

node 'riemann1.local' {

  #class {'riemann':}
  
  class { 'riemann': 
    version => '0.2.5',
  }

  class { 'fail2ban':
    log_level => '3',
  }

  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    ignoreip => ['127.0.0.1', '10.0.1.0/24'],
    logpath  => '/var/log/auth.log',
    maxretry => '10',
    bantime => '3600',
  }

  fail2ban::filter {'sshdtesting':
    daemon => 'sshd',
    failregex => '
      ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
      ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
      ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?(: (ruser .*|(\S+ ID \S+ \(serial \d+\) CA )?\S+ %(__md5hex)s(, client user ".*", client host >
      ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
      ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because listed in DenyUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not in any group\s*$
      ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because none of user\'s groups are listed in AllowGroups\s*$    
    ',
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
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'riemannmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postfix locally so that Fail2Ban can send out emails
  class { '::postfix::server':
    inet_interfaces => 'localhost', #Only listen on localhost
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
  }

}

node 'riemann2.local' {

  class { 'riemann': 
    version => '0.2.5',
  }

  class { 'fail2ban':
    log_level => '3',
  }

  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    ignoreip => ['127.0.0.1', '10.0.1.0/24'],
    logpath  => '/var/log/audit/audit.log',
    maxretry => '10',
    bantime => '3600',
  }

  fail2ban::filter {'sshdtesting':
    daemon => 'sshd',
    failregex => '
      ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
      ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
      ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?(: (ruser .*|(\S+ ID \S+ \(serial \d+\) CA )?\S+ %(__md5hex)s(, client user ".*", client host >
      ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
      ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because listed in DenyUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not in any group\s*$
      ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because none of user\'s groups are listed in AllowGroups\s*$    
    ',
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
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'riemannmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.centos.pool.ntp.org', '1.centos.pool.ntp.org', '2.centos.pool.ntp.org', '3.centos.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postfix locally so that Fail2Ban can send out emails
  class { '::postfix::server':
    inet_interfaces => 'localhost', #Only listen on localhost
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
  }

}

node 'collectd1.local' {

  #Install Apache with the module so we can test measuring Apache stats with Collectd:
  class { 'apache': 
    purge_configs => 'false'
  }
  
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }

  class { 'fail2ban':
    log_level => '3',
  }

  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    ignoreip => ['127.0.0.1', '10.0.1.0/24'],
    logpath  => '/var/log/auth.log',
    maxretry => '10',
    bantime => '3600',
  }

  fail2ban::filter {'sshdtesting':
    daemon => 'sshd',
    failregex => '
      ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
      ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
      ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?(: (ruser .*|(\S+ ID \S+ \(serial \d+\) CA )?\S+ %(__md5hex)s(, client user ".*", client host >
      ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
      ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because listed in DenyUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not in any group\s*$
      ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because none of user\'s groups are listed in AllowGroups\s*$    
    ',
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
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'riemannmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postfix locally so that Fail2Ban can send out emails
  class { '::postfix::server':
    inet_interfaces => 'localhost', #Only listen on localhost
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
  }

  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'riemann1.local',
  }
  
 # class { 'collectd::plugin::write_riemann':
 #   riemann_host => 'riemann1.local',
 #   riemann_port => 5555,
 # }

}

node 'collectd2.local' {

  #Install Apache with the module so we can test measuring Apache stats with Collectd:
  class { 'apache': 
    purge_configs => 'false'
  }
  
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }
  
  class { 'fail2ban':
    log_level => '3',
  }

  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    ignoreip => ['127.0.0.1', '10.0.1.0/24'],
    logpath  => '/var/log/auth.log',
    maxretry => '10',
    bantime => '3600',
  }

  fail2ban::filter {'sshdtesting':
    daemon => 'sshd',
    failregex => '
      ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
      ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
      ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?(: (ruser .*|(\S+ ID \S+ \(serial \d+\) CA )?\S+ %(__md5hex)s(, client user ".*", client host >
      ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
      ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because listed in DenyUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not in any group\s*$
      ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because none of user\'s groups are listed in AllowGroups\s*$    
    ',
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
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'riemannmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  #Install Postfix locally so that Fail2Ban can send out emails
  class { '::postfix::server':
    inet_interfaces => 'localhost', #Only listen on localhost
    inet_protocols => 'all', #Use both IPv4 and IPv6
    mydomain       => 'local',
  }

  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }
  
  collectd::plugin { 'df': }
  collectd::plugin { 'disk': }
  collectd::plugin { 'entropy': }
  collectd::plugin { 'memory': }
  collectd::plugin { 'swap': }
  collectd::plugin { 'cpu': }
  collectd::plugin { 'cpufreq': }
  collectd::plugin { 'contextswitch': }
  
  class { 'collectd::plugin::write_graphite':
    graphitehost => 'riemann1.local',
  }
  
 # class { 'collectd::plugin::write_riemann':
 #   riemann_host => 'riemann1.local',
 #   riemann_port => 5555,
 # }

}

node 'influxdb1.local' {

  class { 'fail2ban':
    log_level => '3',
  }

  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    ignoreip => ['127.0.0.1', '10.0.1.0/24'],
    logpath  => '/var/log/auth.log',
    maxretry => '10',
    bantime => '3600',
  }

  fail2ban::filter {'sshdtesting':
    daemon => 'sshd',
    failregex => '
      ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
      ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
      ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?(: (ruser .*|(\S+ ID \S+ \(serial \d+\) CA )?\S+ %(__md5hex)s(, client user ".*", client host >
      ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
      ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because listed in DenyUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not in any group\s*$
      ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because none of user\'s groups are listed in AllowGroups\s*$    
    ',
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
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'riemannmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}

node 'grafana1.local' {

  #Apache module classes for Grafana:
  class { 'apache': 
    purge_configs => 'false'
  }
  
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }

  class { 'fail2ban':
    log_level => '3',
  }

  fail2ban::jail { 'ssh':
    enabled  => 'true',
    port     => 'ssh',
    filter   => 'sshd',
    ignoreip => ['127.0.0.1', '10.0.1.0/24'],
    logpath  => '/var/log/auth.log',
    maxretry => '10',
    bantime => '3600',
  }

  fail2ban::filter {'sshdtesting':
    daemon => 'sshd',
    failregex => '
      ^%(__prefix_line)s(?:error: PAM: )?[aA]uthentication (?:failure|error) for .* from <HOST>( via \S+)?\s*$
      ^%(__prefix_line)s(?:error: PAM: )?User not known to the underlying authentication module for .* from <HOST>\s*$
      ^%(__prefix_line)sFailed \S+ for .*? from <HOST>(?: port \d*)?(?: ssh\d*)?(: (ruser .*|(\S+ ID \S+ \(serial \d+\) CA )?\S+ %(__md5hex)s(, client user ".*", client host >
      ^%(__prefix_line)sROOT LOGIN REFUSED.* FROM <HOST>\s*$
      ^%(__prefix_line)s[iI](?:llegal|nvalid) user .* from <HOST>\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not listed in AllowUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because listed in DenyUsers\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because not in any group\s*$
      ^%(__prefix_line)srefused connect from \S+ \(<HOST>\)\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because a group is listed in DenyGroups\s*$
      ^%(__prefix_line)sUser .+ from <HOST> not allowed because none of user\'s groups are listed in AllowGroups\s*$    
    ',
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
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'riemannmaster.local',
    port           => '514',
  }

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}