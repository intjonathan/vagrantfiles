class profile::mysql {

}

class profile::mysql::server {

  class { '::mysql::server':
    #hieravaluereplace
    root_password    => 'horsebatterystaple',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
  }

}