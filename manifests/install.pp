class puppet::install ($use_db = false, $use_passenger = false, $add_agent = false, $puppetmaster_name='NONE'){
  if $use_passenger {
    file {
      '/var/lib/puppet/rack':
        ensure => directory,
        owner  => 'puppet',
        group  => 'puppet',
        mode   => '0755';
      '/var/lib/puppet/rack/public':
        ensure => directory,
        owner  => 'puppet',
        group  => 'puppet',
        mode   => '0755',
        require => File['/var/lib/puppet/rack'];
      '/var/lib/puppet/rack/public/puppet':
        ensure => '/usr/lib/ruby/1.8/puppet',
        require => File['/var/lib/puppet/rack/public'];
      '/var/lib/puppet/rack/config.ru':
        ensure => present,
        source => 'puppet:///enovance/puppet/rack/config.ru',
        owner  => 'puppet',
        group  => 'puppet',
        mode   => '0755',
        require => File['/var/lib/puppet/rack'];
    }
    class { 'apache': }
    class { 'apache::ssl': }
    class { 'apache::passenger': }
    package { [ 'apache2-mpm-worker', 'librack-ruby', 'ruby-passenger']:
      ensure => installed,
      require => Class['apache::passenger']
    }

    package { "rack":
      provider => gem,
      ensure   => installed,
    }

    if ($puppetmaster_name == 'NONE') {
      $the_puppetmaster = "$::fqdn"
      $vhost = "$::fqdn"
    } else {
      $vhost = $puppetmaster_name
      $the_puppetmaster = $puppetmaster_name
    }
    file {'/var/www':
      ensure => directory,
      mode   => '0755',
      owner  => 'root',
      group  => 'www-data',
      require => Class['apache']
    }
    apache::virtualhost { "$vhost":
      templatepath => 'enovance/apache/vhosts',
      templatefile => 'passenger_puppet.conf.erb',
      create_docroot => true,
      require => Package['apache'],
    }
  }

  if $use_db != 'UNDEF' {
    package{ 'libactiverecord-ruby1.8': }
    case $use_db {
      'mysql': {
        package { 'libmysql-ruby1.8':
          ensure => present,
        }
        # TODO: find a better system to require thing.  It's all external at the moment.
      }
      'sqlite3': {
        package{ ['sqlite3', 'libsqlite3-ruby1.8']:
          ensure => present,
        }
      }
    }
  }
}
