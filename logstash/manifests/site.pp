#Node definitions

node 'logstashmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
  
  include ssh

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'rsyslog::client':
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    preserve_fqdn  => true,
  }

}

node 'logstash.local' {

  include denyhosts
 
  include ssh

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }
  
  file {'/etc/logstash.conf':
    ensure => file,
    mode => '0644',
    owner => 'root',
    group => 'root',
    source => 'puppet:///logstash/configs/logstash.conf',  
  }

  file {'/etc/blah.conf':
    ensure => file,
    mode => '0644',
    owner => 'root',
    group => 'root',
    source => 'puppet:///logstash/blah.conf',  
  }
  
  class { 'logstash':
    manage_repo => true,
    repo_version => '1.4',
  }
  
  
  #logstash::configfile { 'input_redis':
  #  content => template('logstash/input_redis.erb'),
  #  order   => 10
  #}

}

node 'kibanathree.local' {
  
  include denyhosts

  include ssh

  class{ '::apache':}
  
  ::apache::mod { 'ssl': } #Install/enable the SSL module
  ::apache::mod { 'proxy': } #Install/enable the proxy module
  ::apache::mod { 'proxy_http': } #Install/enable the HTTP proxy module

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'rsyslog::client':
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    preserve_fqdn  => true,
  }  
}

node 'elasticsearch1.local' {

  include denyhosts
  
  class { 'elasticsearch':
    java_install => true,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '4'
      },
      'network' => {
        'host' => $ipaddress_eth1
      },
      'cluster' => {
        'name' => 'logstash',
      }
    }
  }

  elasticsearch::plugin{'mobz/elasticsearch-head':
    module_dir => 'head'
  }

  elasticsearch::plugin{'karmi/elasticsearch-paramedic':
    module_dir => 'paramedic'
  }

  elasticsearch::plugin{'lmenezes/elasticsearch-kopf':
    module_dir => 'kopf'
  }
  
  include ssh

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'rsyslog::client':
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    preserve_fqdn  => true,
  }
  
}

node 'elasticsearch2.local', 'elasticsearch3.local', 'elasticsearch4.local' {
  
  include ssh

  include denyhosts

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'rsyslog::client':
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    preserve_fqdn  => true,
  }

  class { 'elasticsearch':
    java_install => true,
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.1.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '4'
      },
      'network' => {
        'host' => $ipaddress_eth1
      },
      'cluster' => {
        'name' => 'logstash',
      }
    }
  }
  
}

node 'rsyslog1.local', 'rsyslog2.local' {

  include ssh

  include denyhosts

  class { '::ntp':
    servers  => [ '0.ubuntu.pool.ntp.org', '1.ubuntu.pool.ntp.org', '2.ubuntu.pool.ntp.org', '3.ubuntu.pool.ntp.org' ],
    restrict => ['127.0.0.1', '10.0.1.0 mask 255.255.255.0 kod notrap nomodify nopeer noquery'],
    disable_monitor => true,
  }

  class { 'rsyslog::client':
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    server         => 'logstash.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    preserve_fqdn  => true,
  }

}