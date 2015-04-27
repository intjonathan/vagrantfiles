class profile::grafana {

  #A non-SSL virtual host for grafana:
  ::apache::vhost { "grafana.${fqdn}_non-ssl":
    port            => 80,
    #This has to be grafana/grafana so that we don't get duplicated resource errrors from
    #/sites/apps/grafana/ being used by this virtual host resource and by the ::grafana class below: 
    docroot         => '/sites/apps/grafana/grafana',
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
  
  #Install Grafana with this module:
  # https://github.com/bfraser/puppet-grafana
  class { '::grafana':
    version => '1.9.1',
    #This will install Grafana to /sites/apps/grafana/grafana
    #/sites/apps/grafana/grafana will be symlinked to something like /sites/apps/grafana/grafana-1.9.1
    install_dir => '/sites/apps/grafana',
    grafana_user => 'www-data',
    grafana_group => 'www-data',
    datasources  => {
      'influxdbdata' => {
        'type'    => 'influxdb',
        'url'     => 'http://dnsmonitoring.local:8086/db/riemann-data',
        'username' => 'nick',
        'password' => 'password',
        'default' => 'true',
      },
      'grafanadb' => {
        'type'      => 'influxdb',
        'url'       => 'http://dnsmonitoring.local:8086/db/grafana',
        'username' => 'nick',
        'password' => 'password',
        'grafanaDB' => 'true',
      },
    }
  }

}