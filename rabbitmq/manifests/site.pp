#Node definitions

node 'messages1', 'messages2', 'messages3' {
        
    apt::source { 'rabbitmq-apt':
      location   => 'http://www.rabbitmq.com/debian/',
      repos      => "testing main",
      release    => '',
      key        => '056E8E56',
      key_server => 'pgp.mit.edu',
    }


    class {'rabbitmq': }
}