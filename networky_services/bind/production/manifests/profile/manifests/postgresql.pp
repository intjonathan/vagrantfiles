class profile::postgresql { }

class profile::postgresql::server {

  class { '::postgresql::server': }

}