module CommandProposal
  class CommandRunnerJob < ApplicationJob
    queue_as :default

    def perform(iteration_id)
      iteration = ::CommandProposal::Iteration.find(iteration_id)

      ::CommandProposal::Services::Runner.new.execute(iteration)
    end
  end
end
