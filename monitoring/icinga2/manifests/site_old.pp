#puppet master node definition
node 'icinga2master.local' { }

#An Ubuntu 14.04 Icinga2 server node
node 'trustyicinga2server.local' { }

#An Ubuntu 14.10 Icinga2 server node
node 'utopicicinga2server.local' { }

#An Ubuntu 12.04 Icinga2 server node
node 'preciseicinga2server.local' { }

#CentOS 6 Icinga 2 server node
node 'centos6icinga2server.local' { }

#A CentOS 7 Icinga 2 server node
node 'centos7icinga2server.local' { }

#A Debian 7 Icinga2 server node
node 'debian7icinga2server.local' { }

#An Ubuntu 14.04 Icinga 2 client node
node 'trustyicinga2client.local' { }

#An Ubuntu 14.10 Icinga 2 client node
node 'utopicicinga2client.local' { }

#An Ubuntu 12.04 Icinga 2 client node
node 'preciseicinga2client.local' { }

#A CentOS 6 Icinga 2 client node
node 'centos6icinga2client.local' { }

#A CentOS 7 Icinga 2 client node
node 'centos7icinga2client.local' { }

#A Debian 7 Icinga 2 client node
node 'debian7icinga2client.local' { }

node 'icinga2mail.local' { }

node 'usermail.local' { }

node 'icinga2logging.local' { }