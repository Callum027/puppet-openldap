# == Class: openldap::params
#
# Default parameters.
#
# === Parameters
#
# === Variables
#
# === Examples
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2014 Callum Dickinson.
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
