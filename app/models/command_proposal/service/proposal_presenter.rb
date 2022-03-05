module CommandProposal
  module Service
    class ProposalPresenter
      include Rails.application.routes.url_helpers
      include ::CommandProposal::ApplicationHelper
      attr_accessor :iteration

      def initialize(iteration)
        @iteration = iteration
      end

      delegate :name, to: :iteration
      delegate :description, to: :iteration
      delegate :args, to: :iteration
      delegate :code, to: :iteration
      delegate :result, to: :iteration
      delegate :status, to: :iteration
      delegate :approved_at, to: :iteration
      delegate :started_at, to: :iteration
      delegate :completed_at, to: :iteration
      delegate :stopped_at, to: :iteration
      delegate :duration, to: :iteration

      def url
        path = ::CommandProposal::Engine.routes.url_helpers.command_proposal_task_path(@iteration.task)
        "#{base_path}#{path}"
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

      private

      def base_path
        url_opts = Rails.application.config.action_mailer.default_url_options || {}
        url_opts.tap do |opts|
          opts[:protocol] ||= "http"
          opts[:host] ||= "localhost"
          opts[:port] ||= 3000
        end

        port_str = url_opts[:host] == "localhost" ? ":#{url_opts[:port]}" : ""
        "#{url_opts[:protocol] || 'http'}://#{url_opts[:host]}#{port_str}"
      end
    end
  end
end
