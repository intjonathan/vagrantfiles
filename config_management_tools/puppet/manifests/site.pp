#Puppet master

node 'saucymaster.local' {

  #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  class { 'puppetdb::master::config':
    #enable_reports => 'true',
    manage_storeconfigs => 'true',
    manage_routes => 'true',
    manage_report_processor => 'true',
  }

  #Apache modules for PuppetBoard:
  class { 'apache': }
  class { 'apache::mod::wsgi': }

}

#Puppet agents