class role::icinga2 {

}

class role::icinga2::server {

  include profile::postgresql::server
  include profile::icinga2::server
  include profile::icinga2::server::postgresql_db
  include profile::icinga2::server::objects
  
  include profile::icingaweb2::postgresql_db
  include profile::icingaweb2::mysql_db
  
  include profile::mysql::server

  include profile::postfix::server
  
}

class role::icinga2::node {

}