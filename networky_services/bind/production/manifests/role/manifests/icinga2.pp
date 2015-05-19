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

class role::icinga2::nrpeclient {
  
  include profile::icinga2::hostexport
  
  include profile::icinga2::nrpe
  include profile::icinga2::nrpe::objects
  include profile::icinga2::stuff_to_monitor::apache
  include profile::icinga2::stuff_to_monitor::mysql
  include profile::icinga2::stuff_to_monitor::postgresql
  include profile::icinga2::stuff_to_monitor::dovecot


}