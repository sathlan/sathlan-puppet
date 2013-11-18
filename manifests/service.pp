class puppet::service ($use_passenger = false, $daemon_opts = '') {
  if ($use_passenger) {
    $ensure = stopped
    $start  = 'NO'
    $service = 'apache2'
    $enable  = false
  } else {
    $ensure = running
    $start  = 'YES'
    $service = 'puppetmaster'
    $enable  = true
  }
}
