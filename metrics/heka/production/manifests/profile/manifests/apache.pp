#Apache profile

class profile::apache {

}

class profile::apache::wsgi {

  #
  class { '::apache': }
  class { '::apache::mod::wsgi': }

}