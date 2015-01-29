$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require 'medialib_client/version'

Gem::Specification.new do |s|
  s.name              = "medialib_client"
  s.version           = MedialibClient::VERSION
  s.platform          = Gem::Platform::RUBY
  s.author            = "NMD"
  s.email             = ["dmaximov@go-promo.ru"]
  s.homepage          = ""
  s.summary           = "Client side of Medialib"
  s.description       = "Patching Paperclip and js code"
  s.license           = "MIT"

  s.files         = `git ls-files`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency('paperclip', '4.2.0')
  s.add_dependency('rails', '>= 3.2')
  s.add_dependency('coffee-rails')
  s.add_dependency('jquery-rails')
end
