require 'spec_helper'

describe 'puppet' do
  let(:params) { {:dbadapter => 'sqlite3'} }
  it {should include_class('puppet::config')}
  it {should include_class('puppet::install')}
  it {should include_class('puppet::service')}
  it {should include_class('puppet::params')}

  it { should contain_package('libactiverecord-ruby1.8') }
  it { should contain_package('libsqlite3-ruby1.8') }
  it { should contain_package('sqlite3') }
  it { should contain_file('/etc/puppet/puppet.conf') \
      .with_content(/dbadapter .*sqlite3/)}
end
