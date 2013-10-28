node 'snmpclient1.local', 'snmpclient2.local', 'snmpclient3.local' {
  class {'snmp_client':
    agent_ip_addr_range    => '10.0.1.0/24',
    agent_listen_interface => $ipaddress_eth1,
  }
}
