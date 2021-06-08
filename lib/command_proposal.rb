require "command_proposal/configuration"
require "command_proposal/version"
require "command_proposal/engine"
require "command_proposal/services/runner"

module CommandProposal
  class Error < StandardError; end
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= ::CommandProposal::Configuration.new
  end

  def self.reset
    @configuration = ::CommandProposal::Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
