class profile::riemann {

  class { '::riemann': 
    version => '0.2.6',
    riemann_config_source => 'puppet:///riemann/configs/riemann.config',
  }

}