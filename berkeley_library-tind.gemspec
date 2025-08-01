File.expand_path('lib', __dir__).tap do |lib|
  $LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
end

ruby_version = '>= 3.3'

require 'berkeley_library/tind/module_info'

Gem::Specification.new do |spec|
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.name = BerkeleyLibrary::TIND::ModuleInfo::NAME
  spec.authors = BerkeleyLibrary::TIND::ModuleInfo::AUTHORS
  spec.email = BerkeleyLibrary::TIND::ModuleInfo::AUTHOR_EMAILS
  spec.summary = BerkeleyLibrary::TIND::ModuleInfo::SUMMARY
  spec.description = BerkeleyLibrary::TIND::ModuleInfo::DESCRIPTION
  spec.license = BerkeleyLibrary::TIND::ModuleInfo::LICENSE
  spec.version = BerkeleyLibrary::TIND::ModuleInfo::VERSION
  spec.homepage = BerkeleyLibrary::TIND::ModuleInfo::HOMEPAGE

  spec.files = `git ls-files -z`.split("\x0")
  spec.require_paths = ['lib']
  spec.executables << 'tind-export'

  spec.required_ruby_version = ruby_version

  spec.add_dependency 'berkeley_library-alma', '~> 0.1.0'
  spec.add_dependency 'berkeley_library-logging', '~> 0.2'
  spec.add_dependency 'berkeley_library-marc', '~> 0.3.0', '>= 0.3.1'
  spec.add_dependency 'berkeley_library-util', '~> 0.1', '>= 0.1.2'
  spec.add_dependency 'csv', '~> 3.2.2'
  spec.add_dependency 'ice_nine', '~> 0.11'
  spec.add_dependency 'marc', '~> 1.0'
  spec.add_dependency 'rchardet', '~> 1.8'
  spec.add_dependency 'rest-client', '~> 2.1'
  spec.add_dependency 'rubyzip', '~> 2.3', '< 3.0'
  spec.add_dependency 'typesafe_enum', '~> 0.3'

  # rubocop:disable Gemspec/DevelopmentDependencies
  spec.add_development_dependency 'bundle-audit', '~> 0.1'
  spec.add_development_dependency 'ci_reporter_rspec', '~> 1.0'
  spec.add_development_dependency 'colorize', '~> 0.8'
  spec.add_development_dependency 'dotenv', '~> 2.7'
  spec.add_development_dependency 'equivalent-xml', '~> 0.6'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'roo', '~> 2.8'
  spec.add_development_dependency 'rspec', '~> 3.10'
  spec.add_development_dependency 'rubocop', '= 1.77'
  spec.add_development_dependency 'rubocop-rake', '~> 0.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.2'
  spec.add_development_dependency 'ruby-prof', '~> 1.7'
  spec.add_development_dependency 'simplecov', '~> 0.21'
  spec.add_development_dependency 'simplecov-rcov', '~> 0.2'
  spec.add_development_dependency 'webmock', '~> 3.12'
  # rubocop:enable Gemspec/DevelopmentDependencies
end
