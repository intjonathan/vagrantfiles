class profile::puppetdb {

 #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { '::puppetdb':
    listen_address => '0.0.0.0'
  }

}


class profile::puppetdb::master_config {
  
  include ::puppetdb::master::config

}