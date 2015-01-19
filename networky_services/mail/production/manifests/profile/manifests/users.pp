class profile::users {

  #Create a user account so we can test receiving mail:
  user { 'nick':
    ensure => present,
    home => '/home/nick',
    groups => ['sudo', 'admin'],
    #This is 'password', in salted SHA-512 form:
    #hieravaluereplace
    password => '$6$IPYwCTfWyO$bIVTSw4ai/BGtZpfI4HtC8XE7bmb8b3kdZ6gRz4DF4hm7WmD35azXoFxN90TRrSYQdKo011YnBl7p3UXR2osQ1',
    shell => '/bin/bash',
  }

  file { '/home/nick' :
    ensure => directory,
    owner => 'nick',
    group => 'nick',
    mode =>  '755',
  }

}