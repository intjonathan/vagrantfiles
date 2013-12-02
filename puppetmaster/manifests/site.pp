node 'master.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
 include puppetdb::master::config  
}


node 'agent1.local', 'agent2.local', 'agent3.local', 'agent4.local'{

  class {'snmp_client':
    agent_ip_addr_range    => '10.0.1.0/24',
    agent_listen_interface => $ipaddress_eth1,
    vacm_views => ['rouser nick priv'],
  }  
  
  snmp_client::snmpv3user {'nick':
    auth_type => 'SHA',
    auth_secret => 'password',
    priv_type => 'AES',
    priv_secret => 'secret00',
  }

}