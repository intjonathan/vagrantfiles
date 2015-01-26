class profile::dovecot {

  #Create a folder for the SSL cert and private key:
  file { '/etc/dovecot/ssl':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0700',
  }

  class { '::dovecot': 
    #Point Dovecot to maildir folders in user home folders as the place to store delivered mail:
    mail_location => 'maildir:~/Maildir',
    #Enable IMAP with SSL/TLS as a protocol Dovecot uses:
    protocols => 'imap',
    #Enable authentication debugging logs:
    auth_debug => 'yes',
    hostname => $fqdn,
    ssl_cert => "/etc/dovecot/ssl/${fqdn}.pem",
    ssl_key => "/etc/dovecot/ssl/${fqdn}.key",
  }

}