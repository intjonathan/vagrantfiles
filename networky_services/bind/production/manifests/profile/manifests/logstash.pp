class profile::logstash {

 #Install Logstash:  
  class { '::logstash':
    java_install => false,
    package_url => 'https://download.elastic.co/logstash/logstash/packages/debian/logstash_1.4.2-1-2c0f5a1_all.deb',
    install_contrib => true,
    contrib_package_url => 'https://download.elastic.co/logstash/logstash/packages/debian/logstash-contrib_1.4.2-1-efd53ef_all.deb',
  }

  service { 'logstash-web':
    ensure => stopped,
  }

}

class profile::logstash::config {

  ::logstash::configfile { 'logstash_monolithic':
    source => 'puppet:///files/logstash/configs/logstash.conf',
    order   => 10
  }

}