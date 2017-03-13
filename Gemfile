source 'https://rubygems.org'

group :test do
  gem 'rake', ' 10.4.2'
  gem 'puppet', ENV['PUPPET_GEM_VERSION'] || '~> 4.3.0'
  gem 'rspec', '< 3.2.0'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppetlabs_spec_helper'
  gem 'metadata-json-lint'
  gem 'rspec-puppet-facts'
  gem 'rubocop', '0.40.0'
  gem 'simplecov'
  gem 'simplecov-console'

  gem 'puppet-lint-absolute_classname-check'
  gem 'puppet-lint-leading_zero-check'
  gem 'puppet-lint-trailing_comma-check'
  gem 'puppet-lint-version_comparison-check'
  gem 'puppet-lint-classes_and_types_beginning_with_digits-check'
  gem 'puppet-lint-unquoted_string-check'
end

group :development do
  gem 'travis'
  gem 'travis-lint'
  gem 'puppet-blacksmith'
  gem 'guard-rake'
  gem 'puppet-strings', :git => 'https://github.com/puppetlabs/puppetlabs-strings.git'
end

group :acceptance do
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'beaker-puppet_install_helper'
end
