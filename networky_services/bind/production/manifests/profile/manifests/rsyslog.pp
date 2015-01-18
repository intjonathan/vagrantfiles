class profile::rsyslog {

}

class profile::rsyslog::client {

  #This module is from: https://github.com/saz/puppet-rsyslog
  class { '::rsyslog::client':
    #Write out logs in RFC3146 format so that they're more consistent when we send them to
    #Logstash. Logstash is set up to understand this format of logs in its config:
    log_templates => [
      { name => 'RFC3164fmt', template => '<%PRI%>%TIMESTAMP% %HOSTNAME% %syslogtag%%msg%',},
    ],
    log_remote     => true,
    #hieravaluereplace
    server         => 'dnsmonitoring.local',
    port           => '5514',
    remote_type    => 'tcp',
    log_local      => true,
    log_auth_local => true,
    custom_config  => undef,
  }

}

class profile::rsyslog::server {

}