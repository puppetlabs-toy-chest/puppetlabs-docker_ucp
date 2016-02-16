require 'spec_helper_acceptance'

UCP_PORTS = [
  443,
  2376,
  12376,
  12379,
  12380,
  12381,
  12382,
]

UCP_CONTROLLER_CONTAINERS = [
  'controller',
  'swarm-ca-proxy',
  'swarm-ca',
  'ca',
  'swarm-manager',
  'kv',
]

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
    address = fact('osfamily') == 'RedHat' ? fact('ipaddress_enp0s8') : fact('ipaddress_eth1')
    @pp = <<-EOS
      class { 'docker': }
      class { 'docker_ucp':
        ucp_url                   => 'https://#{controller_address}',
        fingerprint               => '#{fingerprint.output.strip}',
        host_address              => '#{address}',
        subject_alternative_names => '#{address}',
        replica                   => true,
        require                   => Class['docker'],
      }
    EOS
    @result = apply_manifest_on_with_exit('node', @pp)
  end

  it_behaves_like 'an idempotent resource'
  it_behaves_like 'a system running docker'
  it_behaves_like 'a system running UCP'
end
