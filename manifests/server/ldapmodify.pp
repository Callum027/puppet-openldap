# == Type: openldap::server::ldapmodify
#
# Add, modify or delete attributes from existing LDAP entries.
#
# === Parameters
#
# Document parameters here.
#
# [*dn*]
#   Distinguished Name (DN) entry to modify. Default is resource title.
#
# [*attrs*]
#   Attributes to modify the entry with. This is defined as an array of hashes.
#
# === Variables
#
# === Examples
#
#  openldap::server::ldapmodify
#  { 'cn=config':
#    attrs =>
#    [
#      { 'olcRootDN' => 'cn=admin,dc=example,dc=com' },
#      { 'olcRootPW' => 'secret' },
#    ],
#  }
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2014 Callum Dickinson.
#
define openldap::server::ldapmodify
(
	$dn		= $title,
	$attrs
)
{
	require openldap::params

	if (!defined(Class["openldap::server"]))
	{
		fail("class openldap::server not defined")
	}

	openldap::server::validate_array_of_hashes
	{ "ldapmodify-$title":
		array	=> $attrs,
	}

	file
	{ "${openldap::params::tmpdir}/ldapmodify-$title.ldif":
		owner	=> $openldap::params::server_owner,
		group	=> $openldap::params::server_group,
		mode	=> $openldap::params::server_mode,
		content	=> template("openldap/ldapmodify.ldif.erb"),
	}

	exec
	{ "${openldap::params::ldapmodify} -Y EXTERNAL -H ldapi:/// -f ${openldap::params::tmpdir}/ldapmodify-$title.ldif":
		require	=> [ Service["slapd"], File["${openldap::params::tmpdir}/ldapmodify-$title.ldif"] ],
	} ->
	exec { "${openldap::params::rm} -f ${openldap::params::tmpdir}/ldapmodify-$title.ldif": }
}
