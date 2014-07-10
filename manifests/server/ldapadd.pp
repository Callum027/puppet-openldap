# == Type: openldap::server::ldapadd
#
# Add new LDAP entries to the directory.
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
#  openldap::server::ldapadd
#  { 'ou=people,dc=example,dc=com':
#    attrs =>
#    [
#      { 'objectClass' => 'posixGroup' },
#      { 'ou'          => 'people' },
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
define openldap::server::ldapadd
(
	$dn	= $title,
	$attrs
)
{
	require openldap::params

	if (!defined(Class["openldap::server"]))
	{
		fail("class openldap::server not defined")
	}

	openldap::server::validate_array_of_hashes
	{ "ldapadd-$title":
		array	=> $attrs,
	}

	# Evaluate the template for the ldapadd call.
	file
	{ "$openldap::params::tmpdir/ldapadd-$title.ldif":
		owner	=> $openldap::params::server_owner,
		group	=> $openldap::params::server_group,
		mode	=> $openldap::params::server_mode,
		content	=> template("openldap/ldapadd.ldif.erb"),
	}

	# Same for the ldapmodify call.
	file
	{ "$openldap::params::tmpdir/ldapadd-ldapmodify-$title.ldif":
		owner	=> $openldap::params::server_owner,
		group	=> $openldap::params::server_group,
		mode	=> $openldap::params::server_mode,
		content	=> template("openldap/ldapmodify.ldif.erb"),
	}

	# Try the ldapmodify call, first of all. This should work if
	# the given DN already exists in the database, and just needs to be updated.
	exec
	{ "$openldap::params::ldapmodify -Y EXTERNAL -H ldapi:/// -f $openldap::params::tmpdir/ldapadd-ldapmodify-$title.ldif":
		require	=> [ Service["slapd"], File["$openldap::params::tmpdir/ldapadd-ldapmodify-$title.ldif"] ],
		onlyif	=> "$openldap::params::ldapsearch -Y EXTERNAL -H ldapi:/// -b \"$dn\"",
	} ->
	exec { "$openldap::params::rm -f $openldap::params::tmpdir/ldapadd-ldapmodify-$title.ldif": } ->
	# Try the ldapadd next, and don't execute it if the given DN exists in
	# the database. This will be run when the DN is initially added to the database.
	exec
	{ "$openldap::params::ldapadd -Y EXTERNAL -H ldapi:/// -f $openldap::params::tmpdir/ldapadd-$title.ldif":
		require	=> [ Service["slapd"], File["$openldap::params::tmpdir/ldapadd-$title.ldif"] ],
		unless	=> "$openldap::params::ldapsearch -Y EXTERNAL -H ldapi:/// -b \"$dn\"",
	} ->
	exec { "$openldap::params::rm -f $openldap::params::tmpdir/ldapadd-$title.ldif": }
}
