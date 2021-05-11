File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

ruby_version = '~> 2.7'

require 'ucblit/tind/module_info'

Gem::Specification.new do |spec|
  spec.name = UCBLIT::TIND::ModuleInfo::NAME
  spec.author = UCBLIT::TIND::ModuleInfo::AUTHOR
  spec.email = UCBLIT::TIND::ModuleInfo::AUTHOR_EMAIL
  spec.summary = UCBLIT::TIND::ModuleInfo::SUMMARY
  spec.description = UCBLIT::TIND::ModuleInfo::DESCRIPTION
  spec.license = UCBLIT::TIND::ModuleInfo::LICENSE
  spec.version = UCBLIT::TIND::ModuleInfo::VERSION
  spec.homepage = UCBLIT::TIND::ModuleInfo::HOMEPAGE

  spec.files = `git ls-files -z`.split("\x0")
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.executables << 'tind-export'

  spec.required_ruby_version = ruby_version

  spec.add_dependency 'ice_nine', '~> 0.11'
  spec.add_dependency 'marc', '~> 1.0'
  spec.add_dependency 'rchardet', '~> 1.8'
  spec.add_dependency 'rest-client', '~> 2.1'
  spec.add_dependency 'rubyzip', '~> 2.3'
  spec.add_dependency 'typesafe_enum', '~> 0.3'
  spec.add_dependency 'ucblit-logging', '~> 0.1', '>= 0.1.1'
  spec.add_dependency 'ucblit-marc', '~> 0.1'

  spec.add_development_dependency 'bundle-audit', '~> 0.1'
  spec.add_development_dependency 'ci_reporter_rspec', '~> 1.0'
  spec.add_development_dependency 'colorize', '~> 0.8'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'listen', '>= 3.0.5', '< 3.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'roo', '~> 2.8'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '= 1.11'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.2'
  spec.add_development_dependency 'ruby-prof', '~> 0.17.0'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'simplecov-rcov', '~> 0.2'
  spec.add_development_dependency 'webmock', '~> 3.12'
end
