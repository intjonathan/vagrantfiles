#default node defition
node default {

}

#puppet master node definition
node 'denymaster.local' {

#  class { 'puppetdb':
#    listen_address => '10.0.1.79'
#  }
  
# include puppetdb::master::config

}

node 'denyclient1' {
  #$message = hiera_array(allowed_hosts)
  
  
  #$print_message = inline_template('<%= [ message.to_a.join("\n") , "\n" ].join %>')
  #$print_message = inline_template('<%= message.join("\n") %>')
  #notify {"your allowed hosts are: ${print_message}":}
  include denyhosts
}