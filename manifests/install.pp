class puppet::install ($use_db = false, $use_passenger = false, $add_agent = false, $puppetmaster_name='NONE'){
  if $use_passenger {
    package {'puppetmaster-passenger':
      ensure => present,
    }
    class { 'apache':
      mpm_module => 'worker',
    }
    class { 'apache::mod::headers': }
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
      docroot         => '/usr/share/puppet/rack/puppetmasterd/public/',
      default_vhost   => true,
      ssl             => true,
      ssl_cert        => "/var/lib/puppet/ssl/certs/${the_puppetmaster}.pem",
      ssl_key         => "/var/lib/puppet/ssl/private_keys/${the_puppetmaster}.pem",
      ssl_chain       => '/var/lib/puppet/ssl/ca/ca_crt.pem',
      ssl_ca          => '/var/lib/puppet/ssl/ca/ca_crt.pem',
      ssl_crl         => '/var/lib/puppet/ssl/ca/ca_crl.pem',
      request_headers => ['unset X-Forwarded-For', 'set X-Client-DN %{SSL_CLIENT_S_DN}e', 'set X-Client-Verify %{SSL_CLIENT_VERIFY}e'],
      custom_fragment => "SSLVerifyClient optional\nSSLVerifyDepth  1\nSSLOptions +StdEnvVars +ExportCertData\nSSLProtocol -ALL +SSLv3 +TLSv1\nSSLCipherSuite ALL:!ADH:RC4+RSA:+HIGH:+MEDIUM:-LOW:-SSLv2:-EXP\n",
      directories     => [
                          {
                          path              => '/usr/share/puppet/rack/puppetmasterd/',
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
    case $use_db {
      'mysql': {
        package{ 'libactiverecord-ruby1.8': }
        package { 'libmysql-ruby1.8':
          ensure => present,
        }
        # TODO: find a better system to require thing.  It's all external at the moment.
      }
      'sqlite3': {
        package{ 'libactiverecord-ruby1.8': }
        package{ ['sqlite3', 'libsqlite3-ruby1.8']:
          ensure => present,
        }
      }
      'puppetdb': {
        file { '/etc/puppet/auth.conf':
          content => template('puppet/auth.conf.erb'),
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          require => Package['puppetmaster-passenger'],
          notify  => Class['Apache::Service'],
        }
        class { 'puppetdb': }
        class { 'puppetdb::master::config':
          puppet_service_name => 'apache2',
        }
      }
    }
  }
}
