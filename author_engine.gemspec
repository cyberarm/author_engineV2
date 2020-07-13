
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "author_engine/version"

Gem::Specification.new do |spec|
  spec.name          = "author_engine"
  spec.version       = AuthorEngine::VERSION
  spec.authors       = ["Cyberarm"]
  spec.email         = ["matthewlikesrobots@gmail.com"]

  spec.summary       = %q{A virtual console that you code in Ruby.}
  spec.description   = %q{Create arcade style games quickly and easily}
  spec.homepage      = "https://github.com/cyberarm/author_engineV2"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib", "assets", "vendor"]

  spec.add_dependency "gosu", "~> 0.15.0"
  spec.add_dependency "coderay", "~> 1.1.2"
  spec.add_dependency "opal", "~> 1.0.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.13"
end
