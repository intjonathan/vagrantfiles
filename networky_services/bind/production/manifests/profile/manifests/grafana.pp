class profile::grafana {

  #A non-SSL virtual host for grafana:
  ::apache::vhost { "grafana.${fqdn}_non-ssl":
    port            => 80,
    docroot         => '/sites/apps/grafana',
    servername      => "grafana.${fqdn}",
    access_log => true,
    access_log_syslog=> 'syslog:local1',
    error_log => true,
    error_log_syslog=> 'syslog:local1',
    custom_fragment => '
      #Disable multiviews since they can have unpredictable results
      <Directory "/sites/apps/grafana">
        AllowOverride All
        Require all granted
        Options -Multiviews
      </Directory>
    ',
  }

}