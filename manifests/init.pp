class puppet(
  $dbpassword,
  $dbadapter         = $puppet::params::dbadapter,
  $dbuser            = $puppet::params::dbuser,
  $dbserver          = $puppet::params::dbserver,
  $environments      = $puppet::params::environments,
  $puppetmaster_name = $puppet::params::puppetserver,
  $reports           = $puppet::params::reports,
  $reporturl         = $puppet::params::reporturl,
  $use_db            = $puppet::params::use_db,
  $config_timeout    = $puppet::params::config_timeout,
  $rack_docroot      = $puppet::params::rack_docroot,
  $version           = $puppet::params::puppet_version,
  $puppet_srv_name   = $puppet::params::puppet_srv_name,
  ) inherits puppet::params {
  anchor { 'puppet::begin'  : } ->
  class  { 'puppet::install': } ~>
  class  { 'puppet::config' : } ~>
  class  { 'puppet::service': } ->
  anchor { 'puppet::end'    : }
}
