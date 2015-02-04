class profile::icinga2::node { 

  class { '::icinga2::node':
    enabled_features => ['checker', 'compatlog']
  }

}