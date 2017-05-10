require 'spec_helper'

describe 'docker_ucp::dtr', :type => :define do
  let(:title) { 'install dtr' }
	let(:facts) { # rubocop:disable Style/BlockDelimiters 
		{ 
		:osfamily                  => 'Debian',
		:operatingsystem           => 'Debian',
		:lsbdistid                 => 'Debian',
		:lsbdistcodename           => 'jessie',
		:kernelrelease             => '3.2.0-4-amd64',
		:operatingsystemmajrelease => '8',
	} }

  context 'with ensure => present and dtr install' do
    let(:params) { # rubocop:disable Style/BlockDelimiters
	    {
	    'install' => true,
	    'dtr_version' => '2.1.3',
            'dtr_external_url' => 'https://foo',
            'ucp_node' => 'foo-bar',
            'ucp_username' => 'admin',
            'ucp_password' => 'foobar',
            'ucp_insecure_tls' => false,
            'dtr_ucp_url' => 'https://bar',
            'replica_id' => 'foobar',    
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('Install dtr') }
  end

  context 'with ensure => present and dtr join' do
    let(:params) { # rubocop:disable Style/BlockDelimiters 
	    {
	    'join' => true,
	    'dtr_version' => '2.1.3',
            'dtr_external_url' => 'https://foo',
            'ucp_node' => 'foo-bar',
            'ucp_username' => 'admin',
            'ucp_password' => 'foobar',
            'ucp_insecure_tls' => false,
            'dtr_ucp_url' => 'https://bar',
            'replica_id' => 'foobar',
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('Join dtr') }
  end

  context 'with ensure => absent' do
    let(:params) { # rubocop:disable Style/BlockDelimiters
	    {
	    'ensure' => 'absent',
	    'dtr_external_url' => 'https://foo',
            'ucp_node' => 'foo-bar',
            'ucp_username' => 'admin',
            'ucp_password' => 'foobar',
            'ucp_insecure_tls' => false,
            'dtr_ucp_url' => 'https://bar',
            'replica_id' => 'foobar',
    } }
    it { is_expected.to compile.with_all_deps }
    it { should contain_exec('Uninstall dtr') }
  end
end
