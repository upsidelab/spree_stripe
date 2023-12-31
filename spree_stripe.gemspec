# encoding: UTF-8
lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'spree_stripe/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_stripe'
  s.version     = SpreeStripe.version
  s.summary     = 'Add extension summary here'
  s.description = 'Add (optional) extension description here'
  s.required_ruby_version = '>= 2.5'

  s.author    = 'Rafal Cymerys'
  s.email     = 'rafal@upsidelab.io'
  s.homepage  = 'https://github.com/spree-contrib/spree_stripe'
  s.license = 'BSD-3-Clause'

  s.files       = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree', '>= 4.6.1'
  s.add_dependency 'spree_extension'
  s.add_dependency 'stripe', '~> 10.1.0'

  s.add_development_dependency 'spree_dev_tools'
end
