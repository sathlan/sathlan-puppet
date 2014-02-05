class puppet::service (
  ) {
  service { $puppet::puppetmaster_service_name:
    ensure  => stopped,
    start   => 'NO',
    enable  => false,
  }
  Class['Puppet::Service'] ~> Class['Apache::Service']
}
