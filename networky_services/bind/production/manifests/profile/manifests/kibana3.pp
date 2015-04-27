class profile::kibana3 {

}

class profile::kibana3::apache_virtualhost {

  #A non-SSL virtual host for Kibana:
  ::apache::vhost { "kibana3.${fqdn}_non-ssl":
    port            => 80,
    #Run out of src/ because we're using a Kibana git checkout:
    docroot         => '/sites/apps/kibana3/src',
    servername      => "kibana3.${fqdn}",
    access_log => true,
    access_log_syslog=> 'syslog:local1',
    error_log => true,
    error_log_syslog=> 'syslog:local1',
    custom_fragment => '
      #Disable multiviews since they can have unpredictable results
      <Directory "/sites/apps/kibana3">
        AllowOverride All
        Require all granted
        Options -Multiviews
      </Directory>
    ',
  }
  
  #Install Kibana 3 with this module: https://github.com/thejandroman/puppet-kibana3
  class { '::kibana3':
    config_es_port      => '9200',
    config_es_protocol  => 'http',
    config_es_server    => 'dnsmonitoring.local',
    manage_ws           => false,
    manage_git          => false,
    k3_install_folder   => '/sites/apps/kibana3',
    #This Git commit SHA1 hash corresponds to v.3.1.2 of Kibana:
    # https://github.com/elasticsearch/kibana/commit/07bbd7ec6c9bd81a1c8922c8b28adedb6dc2160b
    k3_release          => '07bbd7ec6c9bd81a1c8922c8b28adedb6dc2160b',
    k3_folder_owner     => 'www-data',
  }

  #A folder to host Kibana's 3 static files:
  file {'/sites/apps/kibana3': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
  }

}