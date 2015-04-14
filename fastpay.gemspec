# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastpay/version'

Gem::Specification.new do |spec|
  spec.name          = "fastpay"
  spec.version       = Fastpay::VERSION
  spec.authors       = ["yahoowallet"]
  spec.email         = ["fastpay-help@mail.yahoo.co.jp"]
  spec.summary       = %q{FastPay SDK for Ruby}
  spec.description   = %q{FastPay SDK for Ruby}
  spec.homepage      = "https://fastpay.yahoo.co.jp"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "rest-client"
  spec.add_dependency "json"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rspec-its"
  spec.add_development_dependency "webmock"
  spec.add_development_dependency "vcr"
end
