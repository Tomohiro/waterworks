# encoding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'waterworks/version'

Gem::Specification.new do |gem|
  gem.name          = 'waterworks'
  gem.version       = Waterworks::VERSION
  gem.authors       = ['Tomohiro TAIRA']
  gem.email         = ['tomohiro.t@gmail.com']
  gem.description   = 'Pluggable downloader'
  gem.summary       = 'Pluggable downloader'
  gem.homepage      = 'https://github.com/Tomohiro/waterworks'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'mechanize'
  gem.add_runtime_dependency 'nokogiri'

  gem.add_development_dependency 'rake'
end
