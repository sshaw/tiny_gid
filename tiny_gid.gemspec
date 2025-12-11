# frozen_string_literal: true

require_relative "lib/tiny_gid"

Gem::Specification.new do |spec|
  spec.name = "tiny_gid"
  spec.version = TinyGID::VERSION
  spec.authors = ["Skye Shaw"]
  spec.email = ["skye.shaw@gmail.com"]

  spec.description = "TinyGID provides a compact syntax for building Global ID strings for things like GraphQL APIs and Rails apps"
  spec.summary = "Tiny class to build Global ID (gid://) strings from scalar values"
  spec.homepage = "https://github.com/sshaw/tiny_gid"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/sshaw/tiny_gid"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
end
