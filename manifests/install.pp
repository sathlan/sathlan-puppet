class puppet::install (
  ){
  package { $puppet::puppetmaster_passenger_package:
    ensure => $puppet::version,
  }

  class { 'apache':
    mpm_module => 'worker',
  }
  case $puppet::use_db {
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
    'mysql': {
      class { '::mysql::server':
        root_password    => "${puppet::dbpassword}root",
      }
      class { 'mysql::bindings':
        ruby_enable => true,
      }
      mysql_user { "${puppet::mysql_user}@127.0.0.1":
        ensure        => present,
        password_hash => mysql_password($puppet::dbuser),
        require       => Class['mysql::server::service'],
      }
    }
    default: {
      fail("Unsupported database backend ${puppet::use_db}")
    }
  }
}
