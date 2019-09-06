# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'easy_app_helper/version'

Gem::Specification.new do |spec|
  spec.name          = 'easy_app_helper'
  spec.version       = EasyAppHelper::VERSION
  spec.authors       = ['L.Briais']
  spec.email         = ['lbnetid+rb@gmail.com']
  spec.description   = %q{Easy Application Helpers framework}
  spec.summary       = %q{Provides cool helpers to your application, including configuration and logging features}
  spec.homepage      = 'https://github.com/lbriais/easy_app_helper'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 11.2'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'rspec', '~> 3.5'

  spec.add_dependency 'activesupport', '~> 5.0'
  spec.add_dependency 'stacked_config', '~> 2.0.0'
end
