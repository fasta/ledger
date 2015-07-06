# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ledger/version'

Gem::Specification.new do |spec|
  spec.name          = "ledger"
  spec.version       = Ledger::VERSION
  spec.authors       = ["Fabian Staubli"]
  spec.email         = ["fabian@previous.li"]

  spec.summary       = %q{Parses text files written in the Ledger format (http://www.ledger-cli.org).}
  spec.homepage      = "https://github.com/fasta/ledger"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
end
