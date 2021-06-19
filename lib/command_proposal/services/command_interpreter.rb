# require_relative "command_proposal/permissions_helper"

module CommandProposal
  module Services
    class CommandInterpreter
      class Error < StandardError; end
      include ::CommandProposal::PermissionsHelper

      def self.command(iteration, command, user)
        new(iteration, command, user).command
      end

      def initialize(iteration, command, user)
        @iteration = iteration
        @task = iteration.task
        @command = command.to_s.to_sym
        @user = user
        command_user(@user) if @user.present?
      end

      def command
        case @command
        when :request then command_request
        when :approve then command_approve
        when :run then command_run
        when :stop then command_stop
        end
      end

      def command_request
        check_can_command?
        if @iteration.complete?
          # Creates a new iteration with the same code so we don't lose results
          @task.user = @user # Sets the task user to assign as the requester
          @task.update(code: @iteration.code)
          @iteration = @task.current_iteration
        end

        ::CommandProposal.configuration.proposal_callback&.call(@iteration)
      end

      def command_approve
        error!("Command is not ready for approval.") unless @iteration.pending?
        check_can_command? && check_can_approve?

        @iteration.update(status: :approved, approver: @user)
      end

      def command_run
        check_can_command?
        error!("Cannot run without approval.") unless has_approval?(@task)

        # Should be async
        ::CommandProposal::Services::Runner.new.execute(@iteration)
      end

      def command_stop
        check_can_command?

        @iteration.update(status: :stop)
      end

      def check_can_command?
        return true if can_command?

        error!("Sorry, you do not have permission to do this.")
      end

      def check_can_approve?
        return true if can_approve?(@iteration)

        error!("You cannot approve your own command.")
      end

      def error!(msg)
        raise ::CommandProposal::Services::CommandInterpreter::Error.new(msg)
      end
    end
  end
end