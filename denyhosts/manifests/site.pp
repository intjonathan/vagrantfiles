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
  #grab data from hiera
  $message = hiera(allowed_hosts)
  
  #take the values retrieved from hiera and put newlines between them
  $print_message = inline_template('<%= message.join("\n") %>')
  notify {"${print_message}":}
}

node 'denyclient2' {
  #grab data from hiera
  $message = hiera(allowed_hosts)
  
  #take the values retrieved from hiera and put newlines between them
  $print_message = inline_template('<%= message.join("\n") %>')
  notify {"${print_message}":}
}