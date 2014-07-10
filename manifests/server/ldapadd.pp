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
define validate_array_of_hashes_helper($array, $count, $length)
{
	validate_hash($array[$count])

	if ($count < ($length + 1))
	{
		validate_array_of_hashes_helper
		{ "$array-$count-$length":
			array	=> $array,
			count	=> $count + 1,
			length	=> $length,
		}
	}
}

define validate_array_of_hashes($array = $title)
{
	validate_array($array)

	validate_array_of_hashes_helper
	{ "$array":
		array	=> $array,
		count	=> 0,
		length	=> size($array),
	}
}

define openldap::server::ldapadd
(
	$dn	= $title,
	$attrs
)
{
	require openldap::params

	validate_array_of_hashes{ $attrs: }

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
