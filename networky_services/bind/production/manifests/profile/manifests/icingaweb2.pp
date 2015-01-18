class profile::icingaweb2 { }

class profile::icingaweb2::postgresql_db {

  #Create a Postgres DB for Icinga Web 2:
  postgresql::server::db { 'icingaweb2_data':
    #hieravaluereplace
    user     => 'icingaweb2',
    #hieravaluereplace
    password => postgresql_password('icingaweb2', 'password'),
    grant => 'all',
  }
}

class profile::icingaweb2::mysql_db {

  #Create a MySQL database for Icinga Web 2:
  mysql::db { 'icingaweb2_data':
    user     => 'icingaweb2',
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

}