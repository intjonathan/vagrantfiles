#This profile manages the hiera.yaml file and /etc/puppet/hieradata/ directory on Puppet masters:

class profile::hiera {

  class { '::hiera':
    datadir => '/etc/puppet/hieradata/yaml',
    hierarchy => [
      'node/%{fqdn}',
      'operatingsystem/%{operatingsystem}/%{operatingsystemmajrelease}',
      'operatingsystem/%{operatingsystem}',
      'osfamily/%{osfamily}',
      'common',
    ],
  }

}
