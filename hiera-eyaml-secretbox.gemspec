# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hiera/backend/eyaml/encryptors/secretbox'

Gem::Specification.new do |gem|
  gem.name          = "hiera-eyaml-secretbox"
  gem.version       = Hiera::Backend::Eyaml::Encryptors::SecretBox::VERSION
  gem.description   = "NaCl encryptor for use with hiera-eyaml"
  gem.summary       = "Encryption plugin for hiera-eyaml backend for Hiera"
  gem.author        = "Wijnand Modderman-Lenstra"
  gem.email 	    = "maze@pyth0n.org"
  gem.license       = "MIT"

  gem.homepage      = "http://github.com/tehmaze/hiera-eyaml-secretbox"
  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'rbnacl', '~> 3.0'
  gem.add_runtime_dependency 'hiera-eyaml', '~> 2.1'
end
