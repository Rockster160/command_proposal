module CommandProposal
  class CommandRunnerJob < ApplicationJob
    queue_as :default

    def perform(iteration_id, runner_key=nil)
      iteration = ::CommandProposal::Iteration.find(iteration_id)
      runner = ::CommandProposal.sessions[runner_key] if runner_key.present?

      if runner_key.present? && runner.blank?
        if iteration.task.console? && iteration.task.iterations.count > 2 # 1 for init, and the 1 for current running code
          return ::CommandProposal::Services::Runner.new.quick_fail(
            iteration,
            "Session has expired. Please start a new session."
          )
        else
          runner = ::CommandProposal::Services::Runner.new
        end

        ::CommandProposal.sessions[runner_key] = runner if runner_key.present?
      else
        runner ||= ::CommandProposal::Services::Runner.new
      end

      runner.execute(iteration)
    end
  end
end
