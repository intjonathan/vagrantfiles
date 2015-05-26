class profile::icinga2::server { 

  #Install Icinga 2:
  class { '::icinga2::server': 
    server_db_type => 'pgsql',
    db_user        => 'icinga2',
    db_name        => 'icinga2_data',
    db_password    => 'password',
    db_host        => '127.0.0.1',
    db_port        => '5432',
    install_nagios_plugins => false,
    install_mail_utils_package => true,
    server_enabled_features  => ['checker','notification', 'livestatus', 'syslog'],
    server_disabled_features => ['graphite', 'api'],
    purge_unmanaged_object_files => false
  }

  #Collect all @@icinga2::object::host resources from PuppetDB that were exported by other machines:
  Icinga2::Object::Host <<| |>> { }

  #Add a custom config fragment that loads the 
  apache::custom_config { 'icinga2_classicui':
    content => '
      ScriptAlias /cgi-bin/icinga2-classicui /usr/lib/cgi-bin/icinga
      Alias /icinga2-classicui/stylesheets /etc/icinga2-classicui/stylesheets
      Alias /icinga2-classicui /usr/share/icinga2/classicui
      <LocationMatch "^/cgi-bin/icinga2-classicui">
          SetEnv ICINGA_CGI_CONFIG /etc/icinga2-classicui/cgi.cfg
      </LocationMatch>
      <DirectoryMatch "^(?:/usr/share/icinga2/classicui/htdocs|/usr/lib/cgi-bin/icinga2-classicui|/etc/icinga2-classicui/stylesheets)/">
        Options FollowSymLinks
        DirectoryIndex index.html
        AllowOverride AuthConfig
        <IfVersion < 2.3>
          Order Allow,Deny
          Allow From All
        </IfVersion>
        AuthName "Icinga Access"
        AuthType Basic
        AuthUserFile /etc/icinga2-classicui/htpasswd.users
        Require valid-user
      </DirectoryMatch>',
    }


}