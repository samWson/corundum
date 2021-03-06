
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "corundum/version"

Gem::Specification.new do |spec|
  spec.name          = "corundum"
  spec.version       = Corundum::VERSION
  spec.authors       = ["Samuel Wilson"]
  spec.email         = ["samWson@users.noreply.github.com"]
  spec.license       = "BSD-3-Clause"
  spec.summary       = %q{A live programming environment for Ruby.}
  spec.homepage      = "https://github.com/samWson/corundum"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata["source_code_uri"] = spec.homepage
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
  spec.executables   = "corundum"
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 2.3.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rubocop", "~> 1.26", ">= 1.26.1"
end
