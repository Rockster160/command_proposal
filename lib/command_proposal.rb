require "command_proposal/configuration"
require "command_proposal/version"
require "command_proposal/engine"
require "command_proposal/services/runner"
require "command_proposal/services/shut_down"

module CommandProposal
  class Error < StandardError; end
  PAGINATION_PER = 10

  def self.sessions
    @sessions ||= {}
  end

  def self.clear_sessions
    @sessions = {}
  end

  def self.configuration
    @configuration ||= ::CommandProposal::Configuration.new
  end

  def self.reset
    @configuration = ::CommandProposal::Configuration.new
  end

  def self.engine_name
    @engine_name ||= begin
      `bundle exec rails routes | grep command_proposal_engine`.to_s[/\w*command_proposal_engine/]
    end || "command_proposal_engine"
  end

  def self.configure
    yield(configuration)
  end
end
