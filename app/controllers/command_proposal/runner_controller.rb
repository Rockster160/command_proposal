require_dependency "command_proposal/engine_controller"
require "command_proposal/services/command_interpreter"

class ::CommandProposal::RunnerController < ::CommandProposal::EngineController
  include ::CommandProposal::ParamsHelper
  include ::CommandProposal::PermissionsHelper

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

    sleep 0.2
    5.times do |t|
      break if @iteration.reload.complete?

      sleep(0.5)
    end

    iteration_response
  end

  private

  def status_to_code
    case @iteration.status.to_sym
    when :success then :ok
    when :started then :accepted
    when :failed then :ok
    else :not_implemented
    end
    # created
    # approved
    # started
    # failed
    # cancelling
    # cancelled
    # success
  end

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
      format.json { render(json: iteration_json, status: status_to_code) }
    end
  end

  def iteration_json(opts={})
    {
      result: @iteration.result,
      status: @iteration.status,
      duration: humanized_duration(@iteration.duration),
    }.tap do |response|
      if @iteration.started?
        response[:endpoint] = command_proposal.task_runner_path(@task, @iteration)
      end
    end
  end

  def authorize_command!
    return if can_command?

    render text: "Sorry, you are not authorized to do that."
  end
end
