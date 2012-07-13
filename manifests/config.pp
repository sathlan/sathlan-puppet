class puppet::config ($puppet_tmpl = 'UNDEF', $fileserv_templ = 'UNDEF') inherits puppet {
  $puppet_conf = $puppet_tmpl ? {
    'UNDEF' => template('puppet/puppet.conf.erb'),
    default => $puppet_tmpl
  }
  $fileserver_conf = $fileserv_templ ? {
    'UNDEF' => template('puppet/fileserver.conf.erb'),
    default => $fileserv_templ
  }

  file { "/etc/puppet/puppet.conf":
    ensure => present,
    content => $puppet_conf,
    owner => "puppet",
    group => "puppet",
    require => Class["puppet::install"],
    notify => Class["puppet::service"],
  }

  file { "/etc/puppet/fileserver.conf":
    ensure => present,
    content => $fileserver_conf,
    owner => root,
    group => puppet,
    mode => 0640,
    require => Class["puppet::install"],
    notify => Class['puppet::service'],
  }
}
