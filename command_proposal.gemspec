require_relative "lib/command_proposal/version"

Gem::Specification.new do |spec|
  spec.name        = "command_proposal"
  spec.version     = CommandProposal::VERSION
  spec.authors     = ["Rocco Nicholls"]
  spec.email       = ["rocco11nicholls@gmail.com"]

  spec.summary       = "Gives the ability to run approved commands through a UI in your browser"
  spec.description   = "Rather than creating rake tasks, which have to go through CI/CD, then some deploy process, eventually make it to production, only to be run once, and then never get deleted and litter your code base- this gem allows you to create command proposals via a UI that can be immediately reviewed by your peers and then run- keeping a history of what happened, when, and what the results were."
  spec.homepage      = "https://github.com/Rockster160/command_proposal"
  spec.license       = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/Rockster160/command_proposal"
  spec.metadata["changelog_uri"] = "https://github.com/Rockster160/command_proposal/blob/master/README.md"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 6.1.3", ">= 6.1.3.2"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "rubocop", "~> 0.80"
end
