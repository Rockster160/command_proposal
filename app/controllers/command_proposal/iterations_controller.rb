require_dependency "command_proposal/application_controller"

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

    # TODO: REMOVE THIS! Should only be approved by somebody else
    @iteration.update(status: :approved)

    # Should be async
    ::CommandProposal::Services::Runner.new(@iteration).execute

    redirect_to @iteration.task
  end

  private

  def task_params
    params.require(:task).permit(
      :name,
      :description,
      :code,
    )
  end

  def error!(msg="An error occurred.")
    render json: {
      error: msg
    }
  end
end
