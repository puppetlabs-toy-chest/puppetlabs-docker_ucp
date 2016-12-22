require 'spec_helper_acceptance'

UCP_PORTS = [
  443,
  2376,
  12376,
  12379,
  12380,
  12381,
  12382,
].freeze

UCP_CONTROLLER_CONTAINERS = [
  'controller',
  'auth-worker',
  'auth-api',
  'auth-store',
  'cluster-root-ca',
  'swarm-manager',
  'proxy',
  'kv',
].freeze

describe 'docker_ucp' do
  context 'installation' do
    before(:all) do
      address = fact('osfamily') == 'RedHat' ? fact('ipaddress_enp0s8') : fact('ipaddress_eth1')
      @pp = <<-EOS
        class { 'docker': }
        class { 'docker_ucp':
          controller                => true,
          subject_alternative_names => '#{address}',
          host_address              => '#{address}',
          require                   => Class['docker'],
          local_client              => true,
        }
      EOS
      @result = apply_manifest_with_exit(@pp)
    end

    it_behaves_like 'an idempotent resource'
    it_behaves_like 'a system running docker'
    it_behaves_like 'a system running UCP'

    UCP_CONTROLLER_CONTAINERS.each do |name|
      describe docker_container("ucp-#{name}") do
        it { should be_running }
      end
    end

    UCP_PORTS.each do |value|
      describe port(value) do
        it { should be_listening }
      end
    end
  end
end

describe 'docker_ucp join', :node => 'node' do
  before(:all) do
    fingerprint = on('controller', "echo `docker run --rm -v /var/run/docker.sock:/var/run/docker.sock --name ucp docker/ucp fingerprint` | awk -F '=' '{print $2}'")
    controller_address = if fact_on('controller', 'osfamily') == 'RedHat'
                           fact_on('controller', 'ipaddress_enp0s8')
                         else
                           fact_on('controller', 'ipaddress_eth1')
                         end
    address = fact_on('node', 'osfamily') == 'RedHat' ? fact_on('node', 'ipaddress_enp0s8') : fact_on('node', 'ipaddress_eth1')
    @pp = <<-EOS
      class { 'docker': }
      class { 'docker_ucp':
        ucp_url                   => 'https://#{controller_address}',
        fingerprint               => '#{fingerprint.raw_stdout.strip}',
        host_address              => '#{address}',
        subject_alternative_names => '#{address}',
        replica                   => true,
        local_client              => true,
        require                   => Class['docker'],
      }
    EOS
    @result = apply_manifest_on_with_exit('node', @pp)
  end

  it_behaves_like 'a system running docker'
  it_behaves_like 'an idempotent resource' do
    before { skip 'Registering a node now requires a full working license' }
  end
  it_behaves_like 'a system running UCP' do
    before { skip 'Registering a node now requires a full working license' }
  end
end
