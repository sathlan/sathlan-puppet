class puppet::install ($use_db = false, $use_passenger = false, $add_agent = false, $puppetmaster_name='NONE'){
  if $use_passenger {
    file {
      '/var/lib/puppet/rack':
        ensure => directory,
        owner  => 'puppet',
        group  => 'puppet',
        mode   => '0755';
      '/var/lib/puppet/rack/public':
        ensure  => directory,
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0755',
        require => File['/var/lib/puppet/rack'];
      '/var/lib/puppet/rack/public/puppet':
        ensure  => '/usr/lib/ruby/1.8/puppet',
        require => File['/var/lib/puppet/rack/public'];
      '/var/lib/puppet/rack/config.ru':
        ensure  => present,
        source  => 'puppet:///modules/enovance/puppet/rack/config.ru',
        owner   => 'puppet',
        group   => 'puppet',
        mode    => '0755',
        require => File['/var/lib/puppet/rack'];
    }
    exec { 'puppet-fetch-release':
      command => "cd /etc/src/ && wget http://apt.puppetlabs.com/puppetlabs-release-${lsbdistcodename}.deb",
      create  => "/usr/src/puppetlabs-release-${lsbdistcodename}.deb",
    }

    package { "puppetlabs-release-${lsbdistcodename}.deb":
      provider => 'dpkg',
      source   => "/usr/src/puppetlabs-release-${lsbdistcodename}.deb",
      require  => Exec['puppet-fetch-release'],
    }

    class { 'apache':
      mpm_module => 'worker',
    }
    class { 'apache::mod::ssl': }
    class { 'apache::mod::passenger':
      passenger_high_performance  => 'On',
      passenger_pool_idle_time    => 1500,
      passenger_max_pool_size     => 12,
      rack_autodetect             => 'On',
      rails_autodetect            => 'On',
    }
    if ($puppetmaster_name == 'NONE') {
      $the_puppetmaster = $::fqdn
      $vhost = $::fqdn
    } else {
      $vhost = $puppetmaster_name
      $the_puppetmaster = $puppetmaster_name
    }

    apache::vhost { $vhost:
      port            => '8140',
      docroot         => '/var/lib/puppet/rack/public/',
      default_vhost   => true,
      ssl             => true,
      ssl_cert        => "/var/lib/puppet/ssl/certs/${the_puppetmaster}.pem",
      ssl_key         => "/var/lib/puppet/ssl/private_keys/${the_puppetmaster}.pem",
      ssl_chain       => '/var/lib/puppet/ssl/ca/ca_crt.pem',
      ssl_ca          => '/var/lib/puppet/ssl/ca/ca_crt.pem',
      ssl_crl         => '/var/lib/puppet/ssl/ca/ca_crl.pem',
      custom_fragment => "SSLVerifyClient optional\nSSLVerifyDepth  1\nSSLOptions +StdEnvVars\nSSLProtocol -ALL +SSLv3 +TLSv1\nSSLCipherSuite ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP\n",
      directories     => [
                      {
                      path              => '/var/lib/puppet/rack/public/',
                      options           => ['None', '-MultiViews'],
                      order             => 'allow,deny',
                      allow             => 'from all',
                      allowOverride     => ['None'],
                      passenger_enabled => 'on',
                      },
                      ],
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
      'puppetdb': {
        class { 'puppetdb': }
        class { 'puppetdb::master::config': }
      }
    }
  }
}
