# frozen_string_literal: true

require_relative "lib/rrf/version"

Gem::Specification.new do |spec|
  spec.name = "rrf"
  spec.version = Rrf::VERSION
  spec.authors = ["Chris Petersen"]
  spec.email = ["chris@scientist.com"]

  spec.summary = %q{A Ruby gem for Reciprocal Rank Fusion across different search engines}
  spec.description = %q{This gem provides an implementation of Reciprocal Rank Fusion (RRF) to merge results from different search engines. Initially supporting Active Record and Elasticsearch.}
  spec.homepage = "https://github.com/assaydepot/rrf"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
