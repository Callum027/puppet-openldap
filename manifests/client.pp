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
