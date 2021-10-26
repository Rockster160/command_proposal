require_dependency "command_proposal/engine_controller"
require "command_proposal/services/command_interpreter"

class ::CommandProposal::RunnerController < ::CommandProposal::EngineController
  include ::CommandProposal::ParamsHelper
  include ::CommandProposal::PermissionsHelper

  begin
    # Skip load if app attempts to do that
    skip_load_and_authorize_resource
  rescue NameError => e
    nil
  end

  skip_before_action :verify_authenticity_token
  before_action :authorize_command!, except: :error

  def show
    @task = ::CommandProposal::Task.find_by!(friendly_id: params[:task_id])
    @iteration = ::CommandProposal::Iteration.find(params[:id])

    iteration_response
  end

  def create
    @task = ::CommandProposal::Task.find_by!(friendly_id: params[:task_id])
    # Error unless @task.function?
    # Error unless iteration is ready to be run
    @iteration = @task.current_iteration

    begin
      @iteration = run_iteration
    rescue ::CommandProposal::Services::CommandInterpreter::Error => e
      return render(text: e.message, status: :bad_request)
    end

    iteration_response
  end

  private

  def run_iteration
    ::CommandProposal::Services::CommandInterpreter.command(
      @iteration,
      :run,
      command_user,
      iteration_params
    )
  end

  def iteration_params
    { args: params.permit!.to_unsafe_h.except(:action, :controller, :task_id, :runner) }
  end

  def iteration_response
    @iteration.reload

    respond_to do |format|
      format.json { render(json: iteration_json, status: :ok) }
    end
  end

  def iteration_json(opts={})
    {
      result: @iteration.result,
      status: @iteration.status,
      duration: humanized_duration(@iteration.duration),
      started_at: @iteration.started_at&.strftime("%b %-d '%y, %-l:%M%P")
    }.tap do |response|
      if @iteration.started?
        response[:endpoint] = runner_url(@task, @iteration)
      end
      if @task.console?
        response[:result_html] = ApplicationController.render(
          partial: "command_proposal/tasks/console_lines",
          locals: { lines: @task.lines }
        )
      else
        response[:result_html] = ApplicationController.render(
          partial: "command_proposal/tasks/lines",
          locals: { lines: @iteration.result }
        )
      end
    end
  end

  def authorize_command!
    return if can_command?

    render text: "Sorry, you are not authorized to do that."
  end
end
