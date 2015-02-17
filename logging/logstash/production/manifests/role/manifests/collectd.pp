class role::collectd {

  include profile::collectd
  
}

class role::collectd::collectd_system_and_ntp_metrics_and_write_graphite {

  include profile::collectd
  include profile::collectd::system_metrics
  include profile::collectd::ntp_metrics
  include profile::collectd::write_graphite

}