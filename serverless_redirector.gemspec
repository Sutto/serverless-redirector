# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'serverless_redirector/version'

Gem::Specification.new do |spec|
  spec.name          = "serverless_redirector"
  spec.version       = ServerlessRedirector::VERSION
  spec.authors       = ["Darcy Laycock"]
  spec.email         = ["sutto@sutto.net"]

  spec.summary       = %q{S3-Based URL Redirection}
  spec.description   = %q{Manages a S3 bucket providing url redirects based on JSON manifests. Serverless - oh my!}
  spec.homepage      = "https://github.com/Sutto/serverless-redirector"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_dependency 'concurrent-ruby', '~> 1.0'
  spec.add_dependency 'thor'
  spec.add_dependency 'aws-sdk', '>= 2.0', '< 4'
end
