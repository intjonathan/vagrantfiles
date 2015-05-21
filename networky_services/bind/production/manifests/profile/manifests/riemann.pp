class profile::riemann {

  class { '::riemann': 
    version => '0.2.9',
    riemann_config_source => 'puppet:///files/riemann/configs/riemann.config',
  }

  rsyslog::imfile { 'riemann_logs':
    file_name => '/var/log/riemann/riemann.log',
    file_tag => 'riemann',
    file_facility => 'local7',
    file_severity => 'info',
  }

}