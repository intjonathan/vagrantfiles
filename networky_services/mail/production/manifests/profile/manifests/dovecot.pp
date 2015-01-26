class profile::dovecot {

  #Create a folder for the SSL cert and private key:
  file { '/etc/dovecot/ssl':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0400',
  }

  class { '::dovecot': 
    mail_location => 'maildir:~/Maildir',
  }

}