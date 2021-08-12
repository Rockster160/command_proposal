# require_relative "command_proposal/permissions_helper"

module CommandProposal
  module Services
    class CommandInterpreter
      class Error < StandardError; end
      include ::CommandProposal::PermissionsHelper

      def self.command(iteration, command, user, params={})
        new(iteration, command, user, params).command
      end

      def initialize(iteration, command, user, params={})
        @iteration = iteration
        @task = iteration.task
        @command = command.to_s.to_sym
        @user = user
        @params = params
        command_user(@user) if @user.present?
      end

      def command
        case @command
        when :request then command_request
        when :approve then command_approve
        when :run then command_run
        when :cancel then command_cancel
        when :stop then command_stop
        when :close then command_close
        end

        @iteration
      end

      def command_request
        check_can_command?
        if @iteration.complete? && (@task.task? || @task.function?)
          previous_iteration = @iteration
          # Creates a new iteration with the same code so we don't lose results
          @task.user = @user # Sets the task user to assign as the requester
          @task.update(code: @iteration.code)
          @iteration = @task.current_iteration

          if @task.function? && previous_iteration.approved_at?
            @params.merge!(previous_iteration.attributes.slice("approved_at", "approver_id"))
            @params.merge!(status: :approved)
            return # Don't trigger the callback
          end
        end

        ::CommandProposal.configuration.proposal_callback&.call(@iteration)
      end

      def command_approve
        error!("Command is not ready for approval.") unless @iteration.pending?
        check_can_command? && check_can_approve?

        @iteration.update(status: :approved, approver: @user, approved_at: Time.current)
      end

      def command_run
        check_can_command?

        # Rollback the create/update if anything fails
        ActiveRecord::Base.transaction do
          command_request if @task.function? && @iteration.approved_at? && @iteration.complete?
          @iteration.update(@params)

          error!("Cannot run without approval.") unless has_approval?(@task)
        end

        ::CommandProposal::CommandRunnerJob.perform_later(@iteration.id)
      end

      def command_cancel
        check_can_command?

        @iteration.update(status: :cancelled)
      end

      def command_stop
        check_can_command?
        return if @iteration.complete?

        @iteration.update(status: :stop)
      end

      def command_close
        check_can_command?

        @task.first_iteration.update(status: :success)
        ::CommandProposal.sessions.delete("task:#{@task.id}")
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
