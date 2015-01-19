class profile::icinga2::hostexport {

  @@icinga2::object::host { $::fqdn:
    display_name => $::fqdn,
    ipv4_address => $::ipaddress_eth1,
    #hieravaluereplace
    groups => ['linux_servers', 'clients', 'ssh_servers', 'dns_servers'],
    vars => {
      os              => 'linux',
      virtual_machine => 'true',
      distro          => $::operatingsystem,
    },
    target_dir => '/etc/icinga2/objects/hosts',
    target_file_name => "${fqdn}.conf"
  }

}