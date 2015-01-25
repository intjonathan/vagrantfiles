class profile::dovecot {

  class { '::dovecot': 
    mail_location => 'maildir:~/Maildir',
  }

}