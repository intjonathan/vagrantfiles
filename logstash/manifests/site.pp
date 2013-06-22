#Node definitions

node default {
   
}

node 'elasticsearch1', 'elasticsearch2'{

    class {'elasticsearch':
        cluster_name => 'mycluster01',
        bind_interface => 'eth1',
    }
}


node 'logstash' {
    
   class {'logstash': }
}