#NTP profile

class profile::ntp {}

class profile::ntp::server {}

class profile::ntp::client {

  #This module is: https://github.com/puppetlabs/puppetlabs-ntp
  class { '::ntp':
    ##hieravaluereplace
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

}