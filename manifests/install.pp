class puppet::install ($use_db = false, $use_passenger = false, $add_agent = false){
  if $use_passenger {
    # TODO
    class { 'passenger':}
  }
  if $use_db != 'UNDEF' {
    package{ 'libactiverecord-ruby1.8': }
    case $use_db {
      'mysql': {
        # TODO: find a better system to require thing.  It's all external at the moment.
      }
      'sqlite3': {
        package{ ['sqlite3', 'libsqlite3-ruby1.8']:
          ensure => present,
        }
      }
    }
  }
  apt::force { 'puppetmaster':
    release => 'squeeze-backports',
    version => '2.7.14-1',
    require => Class['Enovance::Repository']
  }
  apt::force { 'facter':
    release => 'squeeze-backports',
    version => '1.6.9-2',
    require => Class['Enovance::Repository']
  }
}
