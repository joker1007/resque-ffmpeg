# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'resque-ffmpeg'

Gem::Specification.new do |gem|
  gem.name          = "resque-ffmpeg"
  gem.version       = Resque::Ffmpeg::VERSION
  gem.authors       = ["joker1007"]
  gem.email         = ["kakyoin.hierophant@gmail.com"]
  gem.description   = %q{easier way to use ffmpeg in resque}
  gem.summary       = %q{easier way to use ffmpeg in resque}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "resque"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "tapp"
end
