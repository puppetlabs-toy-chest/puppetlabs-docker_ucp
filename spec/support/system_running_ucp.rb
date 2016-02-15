UCP_IMAGES = [
  'controller',
  'proxy',
  'etcd',
  'cfssl-proxy',
  'cfssl',
  'dsinfo',
]


shared_examples 'a system running UCP' do
	UCP_IMAGES.each do |suffix|
			describe docker_image("docker/ucp-#{suffix}:0.8.0") do
      it { should exist }
    end
  end

	[
		'docker/ucp:latest',
		'swarm:1.1.0-rc2',
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
