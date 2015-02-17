class profile::icinga2::server { 

  #Install Icinga 2:
  class { '::icinga2::server': 
    server_db_type => 'pgsql',
    db_user        => 'icinga2',
    db_name        => 'icinga2_data',
    db_password    => 'password',
    db_host        => '127.0.0.1',
    db_port        => '5432',
    install_nagios_plugins => true,
    install_mail_utils_package => true,
    enabled_features  => ['checker','notification', 'livestatus', 'syslog'],
    disabled_features => ['graphite', 'api'],
    purge_unmanaged_object_files => false
  }

  #Collect all @@icinga2::object::host resources from PuppetDB that were exported by other machines:
  Icinga2::Object::Host <<| |>> { }

}