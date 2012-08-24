class puppet(
  $dbadapter      = 'UNDEF',
  $dbuser         = 'UNDEF',
  $dbpassword     = 'UNDEF',
  $dbserver       = 'UNDEF',
  $dbsocket       = 'UNDEF',
  $certname       = $certname_default,
  $dns_alt_names  = 'UNDEF',
  $prod_modules   = $prod_modules_default,
  $prod_manifest  = $prod_manifest_default,
  $use_passenger   = false,
  $use_development = false,
  $use_testing     = false,
  $add_agent       = false,
  $puppetmaster_name = 'NONE',
  ) inherits puppet::params {
#  include stdlib
#  validate_bool($use_passenger)
#  validate_bool($use_production)
#  validate_bool($use_testing)
#  validate_bool($use_development)
  class { 'puppet::service':
    use_passenger => $use_passenger
  }
  class { 'puppet::install':
    use_db => $dbadapter,
    use_passenger => $use_passenger,
    add_agent     => $add_agent,
    puppetmaster_name => $puppetmaster_name,
  }
  class { 'puppet::config': }
}
