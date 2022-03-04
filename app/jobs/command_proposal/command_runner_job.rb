module CommandProposal
  class CommandRunnerJob < ApplicationJob
    queue_as :default

    def perform(iteration_id, runner_key=nil)
      iteration = ::CommandProposal::Iteration.find(iteration_id)
      runner = ::CommandProposal.sessions[runner_key] if runner_key.present?

      if runner.blank?
        runner = ::CommandProposal::Services::Runner.new

        ::CommandProposal.sessions[runner_key] = runner if runner_key.present?
      end

      runner.execute(iteration)
    end
  end
end
