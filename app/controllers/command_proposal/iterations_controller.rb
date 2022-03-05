require_dependency "command_proposal/engine_controller"
require "command_proposal/services/command_interpreter"

class ::CommandProposal::IterationsController < ::CommandProposal::EngineController
  include ::CommandProposal::ParamsHelper
  helper ::CommandProposal::ParamsHelper
  include ::CommandProposal::PermissionsHelper
  helper ::CommandProposal::PermissionsHelper

  layout "application"

  def show
    @iteration = ::CommandProposal::Iteration.find(params[:id])

    render json: {
      results_endpoint: cmd_path(@iteration),
      result: @iteration.result,
      status: @iteration.status
    }
  end

  def create
    return error!("You do not have permission to run commands.") unless can_command?

    @task = ::CommandProposal::Task.find_by!(friendly_id: params[:task_id])
    # Should rescue/catch and render json
    return error!("Can only run commands on type: :console") unless @task.console?
    return error!("Session has not been approved.") unless has_approval?(@task)

    if @task.iterations.one?
      # Track console details in first iteration
      @task.first_iteration.update(started_at: Time.current, status: :started)
    end

    @task.user = command_user # Separate from update to ensure it's set first
    @task.update(code: params[:code]) # Creates a new iteration
    @iteration = @task.current_iteration
    @iteration.update(status: :approved) # Task was already approved, and this is line-by-line

    # async, but wait for the job to finish
    ::CommandProposal::CommandRunnerJob.perform_later(@iteration.id, "task:#{@task.id}")

    max_wait_seconds = 3
    loop do
      break unless max_wait_seconds.positive?

      max_wait_seconds -= sleep 0.2

      break if @iteration.reload.complete?
    end

    render json: {
      results_endpoint: cmd_path(@iteration),
      result: @iteration.result,
      status: @iteration.status
    }
  end

  def update
    @iteration = ::CommandProposal::Iteration.find(params[:id])

    begin
      alter_command if params.dig(:command_proposal_iteration, :command).present?
    rescue ::CommandProposal::Services::CommandInterpreter::Error => e
      return redirect_to cmd_path(:error, :tasks), alert: e.message
    end

    sleep 0.2

    redirect_to cmd_path(@iteration.task)
  end

  private

  def iteration_params
    {}.tap do |whitelist|
      if params.dig(:command_proposal_iteration, :args).present?
        whitelist[:args] = params.dig(:command_proposal_iteration, :args).permit!.to_h
      end
    end
  end

  def alter_command
    ::CommandProposal::Services::CommandInterpreter.command(
      @iteration,
      params.dig(:command_proposal_iteration, :command),
      command_user,
      iteration_params
    )
  end

  def error!(msg="An error occurred.")
    render json: {
      error: msg
    }
  end
end
