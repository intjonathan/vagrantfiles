class profile::cassandra {

  rsyslog::imfile { 'cassandra':
    file_name => '/var/log/cassandra/cassandra.log',
    file_tag => 'cassandra',
    file_facility => 'local7',
    file_severity => 'info',
  }

  rsyslog::imfile { 'cassandra-system':
    file_name => '/var/log/cassandra/system.log',
    file_tag => 'cassandra-system',
    file_facility => 'local7',
    file_severity => 'info',
  }

}