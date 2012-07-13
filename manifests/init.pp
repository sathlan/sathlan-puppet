class puppet(
  $dbadapter      = 'UNDEF',
  $dbuser         = 'UNDEF',
  $dbpassword     = 'UNDEF',
  $dbserver       = 'UNDEF',
  $dbsocket       = 'UNDEF',
  $certname       = $certname_default,
  $prod_modules   = $prod_modules_default,
  $prod_manifest  = $prod_manifest_default,
  $use_passenger   = false,
  $use_development = false,
  $use_testing     = false
  ) inherits puppet::params {
#  include stdlib
#  validate_bool($use_passenger)
#  validate_bool($use_production)
#  validate_bool($use_testing)
#  validate_bool($use_development)
  class { 'puppet::service': }
  class { 'puppet::install':
    use_db => $dbadapter,
    use_passenger => $use_passenger,
  }
  class { 'puppet::config': }
}
