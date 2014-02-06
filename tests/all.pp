#
# This example file is almost the can be used to build out a sample
# puppetmaster all in one environment with puppetdb and postgresql
#

class { 'puppet':
  dbadapter         => 'puppetdb',
  dbpassword        => 'the_password:)',
  environments      => {
    ci => {
      'manifest_path' => '/etc/puppet/environments/ci/modules/puppet/tests/all.pp',
      'modules_path'  => '/etc/puppet/environments/ci/modules:/etc/puppet/environments/ci/data:/etc/puppet/environments/ci/roles',
    }
  },
  reports           => 'log,store,http,puppetdb',
}

# this part is only required for adding check_multi test.
class { 'monitor': }
class { 'monitor::passenger': }
class { 'monitor::puppet': }
