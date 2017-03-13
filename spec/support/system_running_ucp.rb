UCP_IMAGES = [
  'proxy',
  'cfssl',
  'auth',
  'controller',
  'etcd',
  'compose',
  'auth-store',
  'swarm',
  'dsinfo',
].freeze


shared_examples 'a system running UCP' do
	UCP_IMAGES.each do |suffix|
    describe docker_image("docker/ucp-#{suffix}:1.1.1") do
      it { should exist }
    end
  end

	[
		'docker/ucp:latest',
	].each do |image|
		describe docker_image(image) do
			it { should exist }
		end
	end

  [
    'ucp-swarm-join',
    'ucp-proxy',
  ].each do |container|
    describe docker_container(container) do
      it { should be_running }
    end
  end
end
