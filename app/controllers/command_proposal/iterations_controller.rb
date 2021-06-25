require_dependency "command_proposal/application_controller"
require "command_proposal/services/command_interpreter"

class ::CommandProposal::IterationsController < ApplicationController
  include ::CommandProposal::ParamsHelper
  helper ::CommandProposal::ParamsHelper
  include ::CommandProposal::PermissionsHelper
  helper ::CommandProposal::PermissionsHelper

  layout "application"

  def create
    return error!("You do not have permission to run commands.") unless can_command?

    @task = ::CommandProposal::Task.find(params[:task_id])
    # Should rescue/catch and render json
    return error!("Can only run commands on type: :console") unless @task.console?
    return error!("Session has not been approved.") unless has_approval?(@task)

    if @task.iterations.many?
      runner = ::CommandProposal.sessions["task-#{params[:task_id]}"]
    elsif @task.iterations.one?
      runner = ::CommandProposal::Services::Runner.new
      ::CommandProposal.sessions["task-#{params[:task_id]}"] = runner
    end

    return error!("Session has expired. Please start a new session.") if runner.nil?

    @task.user = command_user # Separate from update to ensure it's set first
    @task.update(code: params[:code]) # Creates a new iteration
    @iteration = @task.current_iteration
    @iteration.update(status: :approved) # Task was already approved, and this is line-by-line

    # in-sync
    runner.execute(@iteration)

    render json: {
      result: @iteration.result
    }
  end

  def update
    @iteration = ::CommandProposal::Iteration.find(params[:id])

    begin
      @iteration.update(iteration_params)
      alter_command if params.dig(:iteration, :command).present?
    rescue ::CommandProposal::Services::CommandInterpreter::Error => e
      return redirect_to error_tasks_path, alert: e.message
    end

    redirect_to @iteration.task
  end

  private

  def iteration_params
    {}.tap do |whitelist|
      if params.dig(:iteration, :args).present?
        whitelist[:args] = params.dig(:iteration, :args).permit!.to_h
      end
    end
  end

  def alter_command
    ::CommandProposal::Services::CommandInterpreter.command(
      @iteration,
      params.dig(:iteration, :command),
      current_user
    )
  end

  def error!(msg="An error occurred.")
    render json: {
      error: msg
    }
  end
end
