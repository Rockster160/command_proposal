module CommandProposal
  class CommandRunnerJob < ApplicationJob
    queue_as :default

    def perform(iteration_id)
      iteration = ::CommandProposal::Iteration.find(iteration_id)

      # Run in a multi thread that continuously reloads the iteration.
      # If iteration is stopped/cancelled, force close the other thread
      # Also ideally the runner continuously retrieves the currently running iterations output

      ::CommandProposal::Services::Runner.new.execute(iteration)
    end
  end
end
