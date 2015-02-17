class profile::kibana4 {

}

class profile::kibana4::apache_virtualhost {

  #A non-SSL virtual host for Kibana:
  ::apache::vhost { "kibana4.${fqdn}_non-ssl":
    port            => 80,
    docroot         => '/sites/apps/kibana4',
    servername      => "kibana4.${fqdn}",
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

  #A folder to host Kibana 4's static files:
  file {'/sites/apps/kibana4': 
      ensure => directory,
      owner => 'www-data',
      group => 'www-data',
      mode => '755',
  }

}