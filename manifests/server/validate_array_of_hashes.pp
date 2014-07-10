# == Type: openldap::server::validate_array_of_hashes
#
# Validate an array of hashes.
#
# === Parameters
#
# Document parameters here.
#
#
# [*array*]
#   Array of hashes to validate.
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
define openldap::server::validate_array_of_hashes_helper($array, $count, $length)
{
	validate_hash($array[$count])

	if ($count < ($length + 1))
	{
		openldap::server::validate_array_of_hashes_helper
		{ "$array-$count-$length":
			array	=> $array,
			count	=> $count + 1,
			length	=> $length,
		}
	}
}

define openldap::server::validate_array_of_hashes($array)
{
	validate_array($array)

	openldap::server::validate_array_of_hashes_helper
	{ "$array":
		array	=> $array,
		count	=> 0,
		length	=> size($array),
	}
}
