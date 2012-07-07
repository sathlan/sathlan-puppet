class puppet::service {
  service { 'puppetmaster':
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    enable  => true,
    require => Class['puppet::install'],
  }
}
