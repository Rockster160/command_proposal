module CommandProposal
  module Services
    module ShutDown
      module_function

      def reset_all
        pending = ::CommandProposal::Iteration.where(status: [:started, :cancelling])
        pending.find_each do |iteration|
          terminate(iteration)
        end
      end

      def terminate(iteration)
        return unless iteration.running?

        terminated_result = "#{iteration&.result}\n\n~~~~~ TERMINATED ~~~~~"
        iteration.update(
          status: :terminated,
          result: terminated_result,
          completed_at: Time.current
        )
      end
    end
  end
end
