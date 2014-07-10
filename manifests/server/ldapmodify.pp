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

define openldap::server::ldapmodify
(
	$dn		= $title,
	$attrs
)
{
	require openldap::params

	validate_array_of_hashes{ $attrs: }

	file
	{ "$openldap::params::tmpdir/ldapmodify-$title.ldif":
		owner	=> $openldap::params::server_owner,
		group	=> $openldap::params::server_group,
		mode	=> $openldap::params::server_mode,
		content	=> template("openldap/ldapmodify.ldif.erb"),
	}

	exec
	{ "$openldap::params::ldapmodify -Y EXTERNAL -H ldapi:/// -f $openldap::params::tmpdir/ldapmodify-$title.ldif":
		require	=> [ Service["slapd"], File["$openldap::params::tmpdir/ldapmodify-$title.ldif"] ],
	} ->
	exec { "$openldap::params::rm -f $openldap::params::tmpdir/ldapmodify-$title.ldif": }
}
