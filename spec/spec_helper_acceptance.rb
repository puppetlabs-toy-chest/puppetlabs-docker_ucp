require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

# automatically load any shared examples or contexts
Dir["./spec/support/**/*.rb"].sort.each { |f| require f }

run_puppet_install_helper unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.formatter = :documentation
  c.before :suite do
    puppet_module_install(:source => proj_root, :module_name => 'docker_ucp')
    # TODO this would benefit from being parallelized
    hosts.each do |host|
      if fact_on(host, 'osfamily') == 'RedHat'
        on(host, 'sudo yum update -y -q')
        on(host, 'sudo systemctl stop firewalld')
      end
      ['puppetlabs-stdlib', 'garethr-docker'].each do |name|
        on host, puppet('module', 'install', name), { :acceptable_exit_codes => [0,1] }
      end
    end
  end
end

def apply_manifest_on_with_exit(host, manifest)
  # acceptable_exit_codes and expect_changes are passed because we want detailed-exit-codes but want to
  # make our own assertions about the responses. Explicit is better than implicit.
  apply_manifest_on(host, manifest, {:acceptable_exit_codes => (0...256), :expect_changes => true, :debug => true})
end

def apply_manifest_with_exit(manifest)
  # acceptable_exit_codes and expect_changes are passed because we want detailed-exit-codes but want to
  # make our own assertions about the responses. Explicit is better than implicit.
  apply_manifest(manifest, {:acceptable_exit_codes => (0...256), :expect_changes => true, :debug => true})
end
