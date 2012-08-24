class puppet::service ($use_passenger = false) {
  if ($use_passenger) {
    $ensure = stopped
  } else {
    $ensure = running
  }
  service { 'puppetmaster':
    ensure => $ensure,
    hasstatus => true,
    hasrestart => true,
    enable  => true,
    require => Class['puppet::install'],
  }
}
