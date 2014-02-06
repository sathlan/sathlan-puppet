class puppet::install (
  ){
  package { $puppet::puppetmaster_package_name:
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
        require => Package[$puppet::puppetmaster_package_name],
        notify  => Class['Apache::Service'],
      }
      class { 'puppetdb':
        database_password => $puppet::dbpassword
      }
      class { 'puppetdb::master::config':
        puppet_service_name => $puppet::puppet_srv_name,
      }
      File <|name == '/etc/puppet/routes.yaml'|> {
        owner => 'root',
        group => 'puppet',
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
