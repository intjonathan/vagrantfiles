class role::collectd {

  include profile::collectd
  
}

class role::collectd::collectd_system_and_ntp_metrics_and_write_graphite {

  include profile::collectd
  include profile::collectd::system_metrics
  #Don't include the NTP CollectD profile, as most of the carbon metrics it generates are 
  #NaN, meaning they don't have any value. 
  #include profile::collectd::ntp_metrics
  include profile::collectd::write_graphite

}