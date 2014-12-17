# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "seiso-import_master"
  spec.version       = "0.0.3.SNAPSHOT"
  spec.authors       = ["Willie Wheeler"]
  spec.email         = ["wwheeler@expedia.com"]
  spec.summary       = "Imports Seiso data master files into Seiso."
  spec.description   = "Supports self-service data management via version control, e.g. by using GitHub."
  spec.homepage      = "http://seiso.io"
  spec.license       = "Apache-2.0"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency "seiso-connector", "~> 0.0"
end
