# == Class: openldap
#
# Full description of class openldap here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { openldap:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class openldap::params
{
	case $::osfamily
	{
		'Debian':
		{
			# General configuration
			$prefix			= "/etc/ldap"
			$tmpdir			= "/tmp"

			# Executable locations
			$ldapadd		= "/usr/bin/ldapadd"
			$ldapmodify		= "/usr/bin/ldapmodify"
			$ldapdelete		= "/usr/bin/ldapdelete"
			$ldapmodrdn		= "/usr/bin/ldapmodrdn"
			$rm			= "/bin/rm"

			# Client configuration options
			$client_packages	= [ "ldap-utils" ]
			$client_conf		= "$prefix/ldap.conf"
			$client_owner		= "root"
			$client_group		= "root"
			$client_mode		= "444"

			# Server configuration options
			$server_packages	= [ "slapd" ]
			$server_service		= "slapd"
			$server_owner		= "openldap"
			$server_group		= "openldap"
			$server_mode		= "440"
		}

		default:
		{
			fail("Sorry, but openldap does not support the $::osfamily OS family at this time")
		}
	}
}
