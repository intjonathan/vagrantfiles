class profile::icinga2::nrpe {

  class { '::icinga2::nrpe':
    #hieravaluereplace
    nrpe_allowed_hosts => ['10.0.1.80', '127.0.0.1'],
    nrpe_listen_port => 5666,
  }

}