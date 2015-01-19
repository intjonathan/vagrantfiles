class profile::puppetexplorer {

  #Most of this profile was adapted from: https://github.com/spotify/puppet-puppetexplorer/blob/master/manifests/init.pp
  $puppetdb_servers   = [ ['production', "http://puppetexplorer.${fqdn}/api"] ]
  $node_facts         = [
    'operatingsystem',
    'operatingsystemrelease',
    'manufacturer',
    'productname',
    'processorcount',
    'memorytotal',
    'ipaddress'
  ]
  $unresponsive_hours = 2
  $dashboard_panels   = [
    {
      name   => 'Unresponsive nodes',
      'type' => 'danger',
      query  => '#node.report-timestamp < @"now - 2 hours"'
    },
    {
      name   => 'Nodes in production env',
      'type' => 'success',
      query  => '#node.catalog-environment = production'
    },
    {
      name   => 'Nodes in non-production env',
      'type' => 'warning',
      query  => '#node.catalog-environment != production'
    }
  ]

  if $osfamily == 'Debian' {
    apt::source { 'puppetexplorer':
      location    => 'http://apt.puppetexplorer.io',
      release     => 'stable',
      repos       => 'main',
      key         => '3FF5E93D',
      include_src => false,
    }
  }

  if $osfamily == 'RedHat' {
    file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-puppetexplorer':
      ensure => file,
      source => 'puppet:///modules/puppetexplorer/RPM-GPG-KEY-puppetexplorer',
      before => Yumrepo['puppetexplorer'],
    }
    yumrepo { 'puppetexplorer':
      ensure        => present,
      descr         => 'Puppet Explorer',
      baseurl       => 'http://yum.puppetexplorer.io/',
      enabled       => true,
      gpgcheck      => 0,
      repo_gpgcheck => 1,
      gpgkey        => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetexplorer',
      before        => Package['puppetexplorer'],
    }
  }

  package { 'puppetexplorer':
    ensure => $package_ensure,
  }

  file { '/usr/share/puppetexplorer/config.js':
    ensure  => file,
    content => template('profile/config.js.erb'),
    require => Package['puppetexplorer'],
  }

  apache::vhost { "puppetexplorer.${fqdn}":
    docroot  => '/usr/share/puppetexplorer/',
    port => 80,
    priority => 30,
    proxy_pass => { 
      'path' => '/api/v4',
      'url' => 'http://127.0.0.1:8080/v4',
      },
  }

}