node 'snmpclient1.local', 'snmpclient2.local', 'snmpclient3.local' {
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
