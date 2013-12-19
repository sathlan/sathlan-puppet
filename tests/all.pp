# file: /etc/puppet/environments/ci/manifest/site.pp
#
# This example file is almost the can be used to build out a sample
# puppetmaster all in one environment with puppetdb and postgresql
#

class { 'puppet':
  dbadapter         => 'puppetdb',
  dbuser            => 'puppet',
  dbpassword        => 'the_password:)',
  dbserver          => '127.0.0.1',
  dbsocket          => '/var/run/mysqld/mysqld.sock',
  certname          => $::fqdn,
  dns_alt_names     => ' ',
  add_agent         => true,
  use_passenger     => true,
  puppetmaster_name => $::fqdn,
  environments      => {
    ci => {
      'manifest_path' => '/etc/puppet/environments/ci/manifest/site.pp',
      'modules_path'  => '/etc/puppet/environments/ci/modules:\
/etc/puppet/environments/ci/data:/etc/puppet/environments/ci/roles',
    }
  },
  reports           => 'log,store,http,puppetdb',
}
