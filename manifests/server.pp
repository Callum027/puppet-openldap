# == Class: openldap::server
#
# Install and configure the slapd service, and add some initial attributes
# to the configuration.
#
# === Parameters
#
# Document parameters here.
#
# [*base*]
# Base Distinguished Name (DN) of the directory.
#
# [*rootdn*]
# Distinguished Name (DN) which is used to modify the base DN directory.
#
# [*rootpw*]
# Password for the root DN.
#
# === Variables
#
# === Examples
#
#  class
#  { openldap::server:
#    base   => 'dc=example,dc=com',
#    # default rootdn is 'cn=admin,$base'
#    rootpw => 'secret',
#  }
#
#  class
#  { openldap::server:
#    base   => 'dc=example,dc=com',
#    rootdn => 'cn=administrator,dc=example,dc=com',
#    rootpw => 'secret',
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
class openldap::server
(
	$base,
	$rootdn	= "cn=admin,$base",
	$rootpw,
)
{
	# Install slapd.
	package
	{ $openldap::params::server_packages:
		ensure	=> installed,
	}

	# Ensure the slapd service is running.
	service
	{ $openldap::params::server_service:
		ensure	=> running,
		enable	=> true,
		require	=> Package[$openldap::params::server_packages],
	}

	# Set up the OpenLDAP client in a specific way, and
	# only allow one instance of openldap::client.
	class
	{ 'openldap::client':
		base	=>	$base,
	}

	# Add some initial attributes to the cn=config entry.
	openldap::server::ldapmodify
	{ "openldap::server::ldapmodify::cn=config":
		dn	=> "cn=config",
		attrs	=>
		[
			{ "olcRootDN"	=> $rootdn },
			{ "olcRootPW"	=> $rootpw },
		],
	}
}
