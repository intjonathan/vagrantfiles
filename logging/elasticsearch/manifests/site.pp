#default node defition
node default {

}

#Puppet master node definition
node 'elasticsearchmaster.local' {

  #This module is from: https://github.com/puppetlabs/puppetlabs-puppetdb/
  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config

  #Apache modules for PuppetBoard:
  class { 'apache': }
  class { 'apache::mod::wsgi': }

  #Configure Puppetboard with this module: https://github.com/nibalizer/puppet-module-puppetboard
  class { 'puppetboard':
    manage_virtualenv => true,
  }

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh
  
  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::server':
    enable_tcp => true,
    enable_udp => true,
    port       => '514',
    server_dir => '/var/log/remote/',
  }
 
}

#Ubuntu ElasticSearch node
node 'elasticsearch1.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

 package {'openjdk-7-jdk':
    ensure => installed,
 }

  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '8'
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

#  elasticsearch::plugin{'andrewvc/elastic-hammer':
#    module_dir => 'hammer'
#  }

#  elasticsearch::plugin{'royrusso/elasticsearch-HQ':
#    module_dir => 'hq'
#  }
 
  elasticsearch::plugin{'polyfractal/elasticsearch-segmentspy':
    module_dir => 'segmentspy'
  }

  elasticsearch::plugin{'polyfractal/elasticsearch-inquisitor':
    module_dir => 'inquisitor'
  }

}

#Ubuntu ElasticSearch node
node 'elasticsearch2.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

 package {'openjdk-7-jdk':
    ensure => installed,
 }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '8'
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

#Ubuntu ElasticSearch node
node 'elasticsearch3.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

 package {'openjdk-7-jdk':
    ensure => installed,
 }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '8'
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

#Ubuntu ElasticSearch node
node 'elasticsearch4.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

 package {'openjdk-7-jdk':
    ensure => installed,
 }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '8'
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

#Ubuntu ElasticSearch node
node 'elasticsearch5.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

 package {'openjdk-7-jdk':
    ensure => installed,
 }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '8'
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

#Ubuntu ElasticSearch node
node 'elasticsearch6.local' {

  #This module is from: https://github.com/saz/puppet-ssh
  include ssh

 package {'openjdk-7-jdk':
    ensure => installed,
 }

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { 'rsyslog::client':
    log_remote     => true,
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
    server         => 'elasticsearchmaster.local',
    port           => '514',
  }

  class { 'elasticsearch':
    package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.0.0.deb',
    config => {
      'node'    => {
        'name' => $fqdn
      },
      'index' => {
        'number_of_replicas' => '1',
        'number_of_shards'   => '8'
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