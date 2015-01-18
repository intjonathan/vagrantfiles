#Role for PuppetDB

class role::puppetdb {

}

class role::puppetdb::puppet_master_and_puppetdb_server {

  include profile::puppetdb
  
  include profile::puppetdb::master_config

}

class role::puppetdb::puppet_master_and_puppetdb_server_with_puppetboard {

  include profile::puppetdb
  
  include profile::puppetdb::master_config
  
  include profile::puppetboard


}