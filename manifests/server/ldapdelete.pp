# == Type: openldap::server::ldapdelete
#
# Delete existing LDAP entries from the directory.
#
# === Parameters
#
# Document parameters here.
#
# [*dn*]
#   Distinguished Name (DN) entry to modify. Default is resource title.
#   Can take an array of strings, to remove multiple entries at once.
#
# === Variables
#
# === Examples
#
#  openldap::server::ldapdelete { 'cn=exampleuser,dc=example,dc=com': }
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2014 Callum Dickinson.
#
define openldap::server::ldapdelete($dn = $title)
{
	# Make sure openldap::params is defined.
	require openldap::params

 	# Check if openldap::server is defined.
	if (!defined(Class["openldap::server"]))
	{
		fail("class openldap::server not defined")
	}

	exec
	{ "$openldap::params::ldapdelete -Y EXTERNAL -H ldapi:/// ${dn}":
		require	=> Service[$openldap::params::server_service],
		returns	=> [ 0, 32 ],
	}
}
