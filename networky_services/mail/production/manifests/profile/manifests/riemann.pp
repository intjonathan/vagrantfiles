class profile::riemann {

  class { '::riemann': 
    version => '0.2.8',
    riemann_config_source => 'puppet:///riemann/configs/riemann.config',
  }

}