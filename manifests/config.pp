class puppet::config () {
  file { '/etc/puppet/puppet.conf':
    ensure  => present,
    content => template('puppet/puppet.conf.erb'),
    owner   => 'puppet',
    group   => 'puppet',
  }

  file { '/etc/puppet/fileserver.conf':
    ensure  => present,
    content => template('puppet/fileserver.conf.erb'),
    owner   => 'root',
    group   => 'puppet',
    mode    => '0640',
  }
  file { '/etc/puppet/autosign.conf':
    ensure  => present,
    content => '*',
    owner   => 'root',
    group   => 'puppet',
    mode    => '0644',
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

  apache::vhost { $::puppet::puppetmaster_name:
    port            => '8140',
    docroot         => '/usr/share/puppet/rack/puppetmasterd/public/',
    default_vhost   => true,
    ssl             => true,
    ssl_cert        => "/var/lib/puppet/ssl/certs/${puppet::puppetmaster_name}.pem",
    ssl_key         => "/var/lib/puppet/ssl/private_keys/${puppet::puppetmaster_name}.pem",
    ssl_chain       => '/var/lib/puppet/ssl/ca/ca_crt.pem',
    ssl_ca          => '/var/lib/puppet/ssl/ca/ca_crt.pem',
    ssl_crl         => '/var/lib/puppet/ssl/ca/ca_crl.pem',
    request_headers => ['unset X-Forwarded-For',
                        'set X-Client-DN %{SSL_CLIENT_S_DN}e',
                        'set X-Client-Verify %{SSL_CLIENT_VERIFY}e'],
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
