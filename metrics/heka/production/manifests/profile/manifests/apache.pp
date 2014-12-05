#Apache profile

class profile::apache {

  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  class { '::apache': 
    purge_configs => 'true'
  }  

  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }

  #Create /sites/apps for Apache to serve static applications out of:
  file {'/sites/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

  file {'/sites/apps/': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
    }

}

class profile::apache::wsgi {

  #This is the Puppet Labs Apache module: https://github.com/puppetlabs/puppetlabs-apache
  class { '::apache': 
    purge_configs => 'true'
  }  

  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module
  ::apache::mod { 'headers': }

  class { '::apache::mod::wsgi': }

}