class profile::icinga2::server::mysql_db {

  #Create a MySQL database for Icinga 2:
  mysql::db { 'icinga2_data':
    user     => 'icinga2',
    #hieravaluereplace
    password => 'password',
    host     => 'localhost',
    grant    => ['ALL'],
  }

  #MySQL IDO connection object
  icinga2::object::idomysqlconnection { 'testing_mysql':
     host             => '127.0.0.1',
     port             => 3306,
     user             => 'icinga2',
     #hieravaluereplace
     password         => 'password',
     database         => 'icinga2_data',
     target_file_name => 'ido-mysql.conf',
     target_dir       => '/etc/icinga2/features-enabled',
     categories       => ['DbCatConfig', 'DbCatState', 'DbCatAcknowledgement', 'DbCatComment', 'DbCatDowntime', 'DbCatEventHandler' ],
  }

}