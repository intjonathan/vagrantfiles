class profile::puppetboard {

  #Configure Puppetboard with this module: https://github.com/nibalizer/puppet-module-puppetboard
  class { '::puppetboard':
    manage_virtualenv => true,
  }

  #A virtualhost for PuppetBoard
  class { '::puppetboard::apache::vhost':
    vhost_name => "puppetboard.${fqdn}",
    port => 80,
  }

}