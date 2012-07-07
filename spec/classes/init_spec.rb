require 'spec_helper'

describe 'puppet' do
  describe "Default sqlite3 configuration." do
    let(:params) { {:dbadapter => 'sqlite3'} }
    let(:facts) { {:fqdn => 'test.example.com'}}
    it {should include_class('puppet::config')}
    it {should include_class('puppet::install')}
    it {should include_class('puppet::service')}
    it {should include_class('puppet::params')}

    it { should contain_package('libactiverecord-ruby1.8') }
    it { should contain_package('libsqlite3-ruby1.8') }
    it { should contain_package('sqlite3') }
    it { should contain_file('/etc/puppet/puppet.conf') \
        .with_content(/dbadapter .*sqlite3/).with_content(/test.example.com.cert/) \
        .with_content(/modulepath .*environments\/production\/modules/)}
  end
  describe "Modulepath is set correctly" do
    let(:params) { {:prod_modules => '/tmp/test'} }
    it { should contain_file('/etc/puppet/puppet.conf') \
        .with_content(/modulepath .*\/tmp\/test/)}
  end
end
