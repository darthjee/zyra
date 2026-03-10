# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zyra/version'

Gem::Specification.new do |gem|
  gem.name                  = 'zyra'
  gem.version               = Zyra::VERSION
  gem.authors               = ['DarthJee']
  gem.email                 = ['darthjee@gmail.com']
  gem.homepage              = 'https://github.com/darthjee/zyra'
  gem.description           = 'Gem for seeding data in the database'
  gem.summary               = gem.description
  gem.required_ruby_version = '>= 3.3.1'

  gem.files                 = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables           = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.require_paths         = ['lib']

  gem.add_dependency 'activesupport', '~> 7.2.x'
  gem.add_dependency 'jace',          '>= 0.1.2'

  gem.metadata['rubygems_mfa_required'] = 'true'
end
