# == Class: openldap::client
#
# Configuration of the LDAP client.
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  include openldap::client
#
# === Authors
#
# Callum Dickinson <callum@huttradio.co.nz>
#
# === Copyright
#
# Copyright 2014 Callum Dickinson.
#
class openldap::client
(
	$uri				= "ldapi:///",
	$base				= undef,
	$binddn				= undef,
	$deref				= undef,
	$host				= undef,
	$network_timeout		= undef,
	$port				= undef,
	$referrals			= undef,
	$sizelimit			= undef,
	$timelimit			= undef,
	$timeout			= undef,

	$sasl_mech			= undef,
	$sasl_realm			= undef,
	$sasl_authcid			= undef,
	$sasl_authzid			= undef,
	$sasl_secprops			= undef,

	$gssapi_sign			= undef,
	$gssapi_encrypt			= undef,
	$gssapi_allow_remote_principal	= undef,

	$tls_cacert			= undef,
	$tls_cacertdir			= undef,
	$tls_cert			= undef,
	$tls_key			= undef,
	$tls_cipher_suite		= undef,
	$tls_randfile			= undef,
	$tls_reqcert			= undef,
	$tls_crlcheck			= undef,
	$tls_crlfile			= undef
)
{
	require openldap::params

	package
	{ $openldap::params::client_packages:
		ensure	=> installed,
	}

	file
	{ "$openldap::params::client_conf":
		owner	=> $openldap::params::client_owner,
		group	=> $openldap::params::client_group,
		mode	=> $openldap::params::client_mode,
		content	=> template("openldap/ldap.conf.erb"),
	}
}
