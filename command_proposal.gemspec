# frozen_string_literal: true

require_relative "lib/command_proposal/version"

Gem::Specification.new do |spec|
  spec.name          = "command_proposal"
  spec.version       = CommandProposal::VERSION
  spec.authors       = ["Rocco Nicholls"]
  spec.email         = ["rocco11nicholls@gmail.com"]

  spec.summary       = "Gives the ability to run approved commands through a UI in your browser"
  spec.description   = "Rather than creating rake tasks, which have to go through CI/CD, then some deploy process, eventually make it to production, only to be run once, and then litter your code base- this gem allows you to create command proposals via a UI that can be immediately reviewed by your peers and then run."
  spec.homepage      = "https://github.com/Rockster160/command_proposal"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Rockster160/command_proposal"
  spec.metadata["changelog_uri"] = "https://github.com/Rockster160/command_proposal/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
