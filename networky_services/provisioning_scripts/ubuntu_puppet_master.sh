#! /bin/bash

#Source the distro release name and version as environment variables:
. /etc/lsb-release

if [ ! -f /home/vagrant/repos_added.txt ];
then    
  sudo wget -N http://apt.puppetlabs.com/puppetlabs-release-${DISTRIB_CODENAME}.deb
  sudo dpkg -i puppetlabs-release-${DISTRIB_CODENAME}.deb
  sudo apt-get update
  #Touch the repos_added file to skip this block the next time around
  touch /home/vagrant/repos_added.txt

else
	echo "Skipping repo addition and package installation..."
fi

if [ ! -f /home/vagrant/puppet_master_installed.txt ];
then
	sudo apt-get -y install puppetmaster
	sudo /etc/init.d/puppetmaster start
	sudo service ufw stop

  sudo cat > /etc/puppet/puppet.conf <<"EOF"
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
environmentpath = $confdir/environments
EOF

sudo cat > /etc/puppet/auth.conf <<"EOF"
# This is the default auth.conf file, which implements the default rules
# used by the puppet master. (That is, the rules below will still apply
# even if this file is deleted.)
#
# The ACLs are evaluated in top-down order. More specific stanzas should
# be towards the top of the file and more general ones at the bottom;
# otherwise, the general rules may "steal" requests that should be
# governed by the specific rules.
#
# See http://docs.puppetlabs.com/guides/rest_auth_conf.html for a more complete
# description of auth.conf's behavior.
#
# Supported syntax:
# Each stanza in auth.conf starts with a path to match, followed
# by optional modifiers, and finally, a series of allow or deny
# directives.
#
# Example Stanza
# ---------------------------------
# path /path/to/resource     # simple prefix match
# # path ~ regex             # alternately, regex match
# [environment envlist]
# [method methodlist]
# [auth[enthicated] {yes|no|on|off|any}]
# allow [host|backreference|*|regex]
# deny [host|backreference|*|regex]
# allow_ip [ip|cidr|ip_wildcard|*]
# deny_ip [ip|cidr|ip_wildcard|*]
#
# The path match can either be a simple prefix match or a regular
# expression. `path /file` would match both `/file_metadata` and
# `/file_content`. Regex matches allow the use of backreferences
# in the allow/deny directives.
#
# The regex syntax is the same as for Ruby regex, and captures backreferences
# for use in the `allow` and `deny` lines of that stanza
#
# Examples:
#
# path ~ ^/path/to/resource    # Equivalent to `path /path/to/resource`.
# allow *                      # Allow all authenticated nodes (since auth
#                              # defaults to `yes`).
#
# path ~ ^/catalog/([^/]+)$    # Permit nodes to access their own catalog (by
# allow $1                     # certname), but not any other node's catalog.
#
# path ~ ^/file_(metadata|content)/extra_files/  # Only allow certain nodes to
# auth yes                                       # access the "extra_files"
# allow /^(.+)\.example\.com$/                   # mount point; note this must
# allow_ip 192.168.100.0/24                      # go ABOVE the "/file" rule,
#                                                # since it is more specific.
#
# environment:: restrict an ACL to a comma-separated list of environments
# method:: restrict an ACL to a comma-separated list of HTTP methods
# auth:: restrict an ACL to an authenticated or unauthenticated request
# the default when unspecified is to restrict the ACL to authenticated requests
# (ie exactly as if auth yes was present).
#

### Authenticated ACLs - these rules apply only when the client
### has a valid certificate and is thus authenticated

# allow nodes to retrieve their own catalog
path ~ ^/catalog/([^/]+)$
method find
allow $1

# allow nodes to retrieve their own node definition
path ~ ^/node/([^/]+)$
method find
allow $1

# allow all nodes to access the certificates services
path /certificate_revocation_list/ca
method find
allow *

# allow all nodes to store their own reports
path ~ ^/report/([^/]+)$
method save
allow $1

# Allow all nodes to access all file services; this is necessary for
# pluginsync, file serving from modules, and file serving from custom
# mount points (see fileserver.conf). Note that the `/file` prefix matches
# requests to both the file_metadata and file_content paths. See "Examples"
# above if you need more granular access control for custom mount points.

path /file
auth yes
allow *

### Unauthenticated ACLs, for clients without valid certificates; authenticated
### clients can also access these paths, though they rarely need to.

# allow access to the CA certificate; unauthenticated nodes need this
# in order to validate the puppet master's certificate
path /certificate/ca
auth any
method find
allow *

# allow nodes to retrieve the certificate they requested earlier
path /certificate/
auth any
method find
allow *

# allow nodes to request a new certificate
path /certificate_request
auth any
method find, save
allow *

path /v2.0/environments
method find
allow *

# deny everything else; this ACL is not strictly necessary, but
# illustrates the default policy.
path /
auth any
EOF

sudo cat > /etc/puppet/fileserver.conf <<"EOF"
# fileserver.conf

# Puppet automatically serves PLUGINS and FILES FROM MODULES: anything in
# <module name>/files/<file name> is available to authenticated nodes at
# puppet:///modules/<module name>/<file name>. You do not need to edit this
# file to enable this.

# MOUNT POINTS

# If you need to serve files from a directory that is NOT in a module,
# you must create a static mount point in this file:
#
# [extra_files]
#   path /etc/puppet/files
#   allow *
#
# In the example above, anything in /etc/puppet/files/<file name> would be
# available to authenticated nodes at puppet:///extra_files/<file name>.
#
# Mount points may also use three placeholders as part of their path:
#
# %H - The node's certname.
# %h - The portion of the node's certname before the first dot. (Usually the
#      node's short hostname.)
# %d - The portion of the node's certname after the first dot. (Usually the
#      node's domain name.)

# PERMISSIONS

# Every static mount point should have an `allow *` line; setting more
# granular permissions in this file is deprecated. Instead, you can
# control file access in auth.conf by controlling the
# /file_metadata/<mount point> and /file_content/<mount point> paths:
#
# path ~ ^/file_(metadata|content)/extra_files/
# auth yes
# allow /^(.+)\.example\.com$/
# allow_ip 192.168.100.0/24
#
# If added to auth.conf BEFORE the "path /file" rule, the rule above
# will add stricter restrictions to the extra_files mount point

[files]
  path /etc/puppet/files
  allow *

EOF

sudo cat > /etc/puppet/hiera.yaml <<"EOF"
---
#Our hierarcy
:hierarchy:
  - node/%{fqdn}
  - operatingsystem/%{operatingsystem}
  - osfamily/%{osfamily}
  - common
#List the backends we want to use
:backends:
 - yaml
#For the YAML backend, specify the location of YAML data
:yaml:
  :datadir: '/etc/puppet/hieradata/yaml'
EOF

  sudo /etc/init.d/puppetmaster stop
  sudo puppet cert clean --all
  sudo puppet cert generate master --dns_alt_names=puppet,master,puppetmaster,puppet.local,master.local,puppetmaster.local >/dev/null
  sudo /etc/init.d/puppetmaster restart
  #Touch the puppet_installed.txt file to skip this block the next time around
  touch /home/vagrant/puppet_master_installed.txt
else
	echo "Skipping Puppet master installation..."
fi

if [ ! -f /home/vagrant/puppet_master_initial_run_complete.txt ];
then
  #Do an initial Puppet run to set up PuppetDB:
  puppet agent -t
  #Enable PuppetDB report storage...
  echo 'reports = store,puppetdb' >> /etc/puppet/puppet.conf
  #...and restart PuppetDB:
  service puppetmaster restart
  #Touch the puppet_master_initial_run_complete.txt file to skip this block the next time around
  touch /home/vagrant/puppet_master_initial_run_complete.txt
else
  echo "Skipping initial Puppet run..."
fi