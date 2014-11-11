 #Create an HTTP check command to test out this PR: https://github.com/Icinga/puppet-icinga2/pull/29
  icinga2::object::checkcommand { 'check_http':
    target_dir => '/etc/icinga2/objects/checkcommands',
    command => ['"/check_http"'],
    arguments     => {'"-H"'             => '"$http_vhost$"',
      '"-I"'          => '"$http_address$"',
      '"-u"'          => '"$http_uri$"',
      '"-p"'          => '"$http_port$"',
      '"-S"'          => {
        'set_if' => '"$http_ssl$"'
      },
      '"--sni"'       => {
        'set_if' => '"$http_sni$"'
      },
      '"-a"'          => {
        'value'       => '"$http_auth_pair$"',
        'description' => '"Username:password on sites with basic authentication"'
      },
      '"--no-body"'   => {
        'set_if' => '"$http_ignore_body$"'
      },
      '"-r"' => '"$http_expect_body_regex$"',
      '"-w"' => '"$http_warn_time$"',
      '"-c"' => '"$http_critical_time$"',
      '"-e"' => '"$http_expect$"'
    },
    vars => {
      'vars.http_address' => '"$address$"',
      'vars.http_ssl'     => 'false',
      'vars.http_sni'     => 'false'
    }
  }

  #Create a notification command object to test this PR: https://github.com/Icinga/puppet-icinga2/pull/32
#  icinga2::object::notificationcommand { 'mail-service-notification2':
#    command   => ['"/icinga2/scripts/mail-notification.sh"'],
#    cmd_path  => 'SysconfDir',
#    env       => {
#      'NOTIFICATIONTYPE'  => '"$notification.type$"',
#      'SERVICEDESC' => '"$service.name$"',
#      'HOSTALIAS' => '"$host.display_name$"',
#      'HOSTADDRESS' => '"$address$"',
#      'SERVICESTATE' => '"$service.state$"',
#      'LONGDATETIME' => '"$icinga.long_date_time$"',
#      'SERVICEOUTPUT' => '"$service.output$"',
#      'NOTIFICATIONAUTHORNAME' => '"$notification.author$"',
#      'NOTIFICATIONCOMMENT' => '"$notification.comment$"',
#      'HOSTDISPLAYNAME' => '"$host.display_name$"',
#      'SERVICEDISPLAYNAME' => '"$service.display_name$"',
#      'USEREMAIL' => '"$user.email$"'
#    }
#  }