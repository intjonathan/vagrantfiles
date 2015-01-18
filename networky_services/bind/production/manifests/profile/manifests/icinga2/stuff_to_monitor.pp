class profile::icinga2::stuff_to_monitor {

}

class profile::icinga2::stuff_to_monitor::apache {

  #Install some stuff to monitor like...
  
  #...Apache:
  class{ '::apache':}
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'rewrite': } #Install/enable the rewrite module

}

class profile::icinga2::stuff_to_monitor::mysql {

  #...and install MySQL as well:
  class { '::mysql::server':
    #hieravaluereplace
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

  #Create a MySQL test database for Icinga 2 to monitor:
  mysql::db { 'test_data':
    user     => 'test',
    #hieravaluereplace
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

}

class profile::icinga2::stuff_to_monitor::postgresql {

  #Install Postgres so we can monitor it with Icinga 2...
  class { 'postgresql::server': }

  #Create a Postgres test DB for Icinga 2 to monitor:
  postgresql::server::db { 'test_data':
    user     => 'tester',
    #hieravaluereplace
    password => postgresql_password('tester', 'password'),
  }

}

class profile::icinga2::stuff_to_monitor::postfix {

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

}

class profile::icinga2::stuff_to_monitor::dovecot {

}