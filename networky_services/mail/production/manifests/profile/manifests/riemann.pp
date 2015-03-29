class profile::riemann {

  class { '::riemann': 
    version => '0.2.9',
    riemann_config_source => 'puppet:///riemann/configs/riemann.config',
  }

}