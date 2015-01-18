class profile::logstash {

 #Install Logstash:  
  class { '::logstash':
    java_install => false,
    package_url => 'https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb',
    install_contrib => true,
    contrib_package_url => 'https://download.elasticsearch.org/logstash/logstash/packages/debian/logstash-contrib_1.4.2-1-efd53ef_all.deb',
  }

}

class profile::logstash::config {

  ::logstash::configfile { 'logstash_monolithic':
    source => 'puppet:///logstash/configs/logstash.conf',
    order   => 10
  }

}