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
	$rootpw
)
{
	# Make sure openldap::params is defined.
	require openldap::params

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
	# The root DN and it's password, as well as the access control list
	# attributes required for the module to work properly.
	openldap::server::ldapmodify
	{ "openldap::server::ldapmodify::olcDatabase={1}hdb,cn=config":
		dn	=> "olcDatabase={1}hdb,cn=config",
		attrs	=>
		[
			{ "olcRootDN"	=> $rootdn },
			{ "olcRootPW"	=> $rootpw },

			{ "olcAccess"	=> "{0}to attrs=userPassword,shadowLastChange by self write by anonymous auth by dn=\"$rootdn\" write by * none" },
			{ "olcAccess"	=> "{1}to dn.base=\"\" by * read" },
			# SUPER IMPORTANT. This olcAccess attribute is required for the openldap::server
			# module to be able to modify records in the directory!
			{ "olcAccess"	=> "{2}to * by self write by dn.exact=\"gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth\" manage by dn=\"$rootdn\" write by * read" },
		],
	}
}
