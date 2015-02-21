class profile::collectd {

  #Install Collectd so we can get metrics from this machine into heka/InfluxDB:
  class { '::collectd':
    purge        => true,
    recurse      => true,
    purge_config => true,
  }

}

class profile::collectd::system_metrics {

  ::collectd::plugin { 'df': }
  ::collectd::plugin { 'disk': }
  ::collectd::plugin { 'entropy': }
  ::collectd::plugin { 'memory': }
  ::collectd::plugin { 'swap': }
  ::collectd::plugin { 'cpu': }
  ::collectd::plugin { 'cpufreq': }
  ::collectd::plugin { 'contextswitch': }
  ::collectd::plugin { 'processes': }
  ::collectd::plugin { 'vmem': }
  class { '::collectd::plugin::load':}

}

class profile::collectd::ntp_metrics {

  #Gather NTP stats:
  class { '::collectd::plugin::ntpd':
    host           => 'localhost',
    port           => 123,
    reverselookups => false,
    includeunitid  => false,
  }

}

class profile::collectd::write_graphite {

  #Write the collectd status to the heka VM in the Graphite format:
  class { '::collectd::plugin::write_graphite':
    graphitehost => 'hekamonitoring.local',
    protocol => 'tcp',
    graphiteport => 2003,
  }

}

class profile::collectd::write_riemann {



}