#default node defition
node default {

  include ssh

}

#Puppet master node definition
node 'elasticsearchmaster.local' {

  class { 'puppetdb':
    listen_address => '0.0.0.0'
  }
  
  include puppetdb::master::config
 
}

#Ubuntu ElasticSearch node
node 'elasticsearch1.local' {

}

#Ubuntu ElasticSearch node
node 'elasticsearch2.local' {

}

#Ubuntu ElasticSearch node
node 'elasticsearch3.local' {

}

#Ubuntu ElasticSearch node
node 'elasticsearch4.local' {

}

#Ubuntu ElasticSearch node
node 'elasticsearch5.local' {

}

#Ubuntu ElasticSearch node
node 'elasticsearch6.local' {

}