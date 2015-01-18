class profile::java {
  
  #Install the JDK with the Puppet Labs Java module:

  class { '::java':
    distribution => 'jre',
  }

  
}