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
  service { "puppetmaster":
    ensure => $ensure,
    hasstatus => true,
    hasrestart => true,
    enable  => $enable,
    require => Class['puppet::install'],
  }
  if ($::osfamily == 'Debian') {
    file {'/etc/default/puppetmaster':
      content => template('puppet/default-puppetmaster.erb'),
      owner   => 'root',
      group   => 'root',
      mode    => '0544',
      require => Class['puppet::install'],
    }
  }
}
