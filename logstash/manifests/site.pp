#Node definitions

node default {
   
}

node 'elasticsearch1', 'elasticsearch2', 'elasticsearch3', 'elasticsearch4' {

    class {'elasticsearch':
        cluster_name => 'mycluster01',
        bind_interface => 'eth1',
    }
}
