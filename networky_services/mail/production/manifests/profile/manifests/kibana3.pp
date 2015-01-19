class profile::kibana3 {

}

class profile::kibana3::apache_virtualhost {

  #A non-SSL virtual host for Kibana:
  ::apache::vhost { "kibana3.${fqdn}_non-ssl":
    port            => 80,
    docroot         => '/sites/apps/kibana3',
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

}