class profile::icinga2::server::postgresql_db {

  #Create a Postgres DB for Icinga 2:
  postgresql::server::db { 'icinga2_data':
    user     => 'icinga2',
    #hieravaluereplace
    password => postgresql_password('icinga2', 'password'),
    grant => 'all',
  }

  #Postgres IDO connection object:
  icinga2::object::idopgsqlconnection { 'testing_postgres':
     host             => '127.0.0.1',
     port             => 5432,
     #hieravaluereplace
     user             => 'icinga2',
     #hieravaluereplace
     password         => 'password',
     database         => 'icinga2_data',
     target_file_name => 'ido-pgsql.conf',
     target_dir       => '/etc/icinga2/features-enabled',
     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

}