class puppet::install ($use_db = false, $use_passenger = false){

  if $use_passenger {
    # TODO
    class { 'passenger':}
  }
  if $use_db != 'UNDEF' {
    package{ 'libactiverecord-ruby1.8':
      ensure => present,
    }
    case $use_db {
      'mysql': {
        # TODO
        class { 'mysql': }
      }
      'sqlite3': {
        package{ ['sqlite3', 'libsqlite3-ruby1.8']:
          ensure => present,
        }
      }
    }
  }
  package { 'puppetmaster-common':
    ensure => '2.7.14-1~bpo60+1'
  }
  package { 'puppetmaster':
    ensure => '2.7.14-1~bpo60+1',
    require => Package['puppetmaster-common'],
  }
  package { 'facter':
    ensure => '1.6.9-2~bpo60+2',
    require => Package['puppetmaster-common'],
  }
}
