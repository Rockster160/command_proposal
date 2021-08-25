module CommandProposal
  module Service
    class ProposalPresenter
      include ::CommandProposal::ApplicationHelper
      attr_accessor :iteration

      def initialize(iteration)
        @iteration = iteration
      end

      delegate :name, to: :iteration
      delegate :description, to: :iteration
      delegate :args, to: :iteration
      delegate :code, to: :iteration
      delegate :status, to: :iteration
      delegate :approved_at, to: :iteration
      delegate :started_at, to: :iteration
      delegate :completed_at, to: :iteration
      delegate :stopped_at, to: :iteration
      delegate :duration, to: :iteration

      def url(host: nil)
        cmd_path(@iteration.task, host: host)
      end

      def requester
        @iteration.requester_name
      end

      def approver
        @iteration.approver_name
      end

      def type
        @iteration.session_type
      end
    end
  end
end
