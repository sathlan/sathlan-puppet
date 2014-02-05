class puppet::params {

  case $::operatingsystem {
    'centos', 'redhat', 'fedora': {
      $puppetmaster_package_name      = 'puppet-server'
      $puppetmaster_service_name      = 'puppetmaster'
      $puppetmaster_passenger_package = 'puppetmaster-passenger'
      package { 'puppetlabs-release':
        ensure   => present,
        source   => "http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6.10.noarch.rpm",
        provider => rpm,
      }
    }
    'ubuntu', 'debian': {
      $puppetmaster_package_name      = 'puppetmaster'
      $puppetmaster_service_name      = 'puppetmaster'
      $puppetmaster_passenger_package = 'puppetmaster-passenger'
      exec { 'get_repo':
        command => "wget https://apt.puppetlabs.com/puppetlabs-release-${::lsbdistcodename}",
        cwd     => '/usr/src',
        creates => "/usr/src/puppetlabs-release-${::lsbdistcodename}.deb",
      }

      package { "puppetlabs-releas-${::lsbdistcodename}":
        ensure   => present,
        provider => 'dpkg',
        source   => "/usr/src/puppetlabs-release-${::lsbdistcodename}.deb",
      }
    }

    default: {
      fail("Unsupported osfamily: ${::osfamily} operatingsystem: ${::operatingsystem}, module ${module_name} only support osfamily RedHat and Debian")
    }
  }

  $puppetserver          = $::fqdn
  $module_base_path      = '/etc/puppet/environments'
  $environments          = {
    'production' => {
      'manifest_path'  => '/etc/puppet/environments/production/manifests/site.pp',
      'modules_path'   => '/etc/puppet/environments/production/modules',
    }
  }
  $modules_default       = "${module_base_path}/production/modules"
  $manifest              = "${module_base_path}/production/manifests/site.pp"
  $use_db                = 'puppetdb'
  $reporturl             = false
  $config_timeout        = 300
  $reports               = 'log'
  $dbserver              = '127.0.0.1'
  $dbuser                = 'puppet'
  $puppet_version        = '3.4.2-1' #2.7.25-1
}
