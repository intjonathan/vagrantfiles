class profile::icinga2::nrpe {

  class { '::icinga2::nrpe':
    nrpe_allowed_hosts => ['10.0.1.81', '10.0.1.82', '10.0.1.83', '10.0.1.84', '10.0.1.92', '127.0.0.1'],
  }

}