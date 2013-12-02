node 'master.local' {

  class { 'puppetdb':
    listen_address => $ipaddress_eth1
  }
  
 include puppetdb::master::config  
}


node 'agent1.local' {

}