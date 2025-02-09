# frozen_string_literal: true

require_relative "lib/cva/version"

Gem::Specification.new do |spec|
  spec.name = "cva_rails"
  spec.version = Cva::VERSION
  spec.authors = ["Volodymyr Partytskyi"]
  spec.email = ["volodymyr.partytskyi@gmail.com"]

  spec.summary = "cva(Class Variance Authority) for rails views."
  spec.description = "A Rails helper designed to generate and manage multiple style " \
                     "or configuration variants for components, enabling flexible and dynamic " \
                     "customization based on provided parameters."
  spec.homepage = "https://github.com/defvova/cva_rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile Rakefile .rubocop])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata["rubygems_mfa_required"] = "true"

  spec.add_dependency "actionview", ">= 6.1"
  spec.add_dependency "clsx-rails", ">= 1.0"
end
