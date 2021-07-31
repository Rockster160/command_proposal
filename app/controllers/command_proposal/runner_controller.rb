require_dependency "command_proposal/application_controller"
require "command_proposal/services/command_interpreter"

class ::CommandProposal::RunnerController < ApplicationController
  include ::CommandProposal::ParamsHelper
  include ::CommandProposal::PermissionsHelper

  skip_before_action :verify_authenticity_token
  before_action :authorize!, except: :error

  def show
    @task = ::CommandProposal::Task.find(params[:task_id])
    @iteration = ::CommandProposal::Iteration.find(params[:id])

    iteration_response
  end

  def create
    @task = ::CommandProposal::Task.find(params[:task_id])
    # Error unless @task.function?
    # Error unless iteration is ready to be run
    @iteration = @task.current_iteration

    begin
      @iteration = run_iteration
    rescue ::CommandProposal::Services::CommandInterpreter::Error => e
      return render(text: e.message, status: :bad_request)
    end

    sleep 0.2
    3.times do |t|
      next sleep(1) unless @iteration.reload.complete?

      return iteration_response
    end

    iteration_response
  end

  private

  def status_to_code
    case @iteration.status.to_sym
    when :success then :ok
    when :started then :accepted
    when :failed then :unprocessable_entity
    when :stop, :stopped then :ok
    else :not_implemented
    end
    # created
    # approved
    # started
    # failed
    # cancelled
    # stop
    # stopped
    # success
  end

  def run_iteration
    ::CommandProposal::Services::CommandInterpreter.command(
      @iteration,
      # approval_required? :request : :run
      :run,
      current_user,
      iteration_params
    )
  end

  def iteration_params
    { args: params.permit!.to_unsafe_h.except(:action, :controller, :task_id, :runner) }
  end

  def iteration_response
    @iteration.reload

    respond_to do |format|
      format.html { render(json: iteration_json(html: true), status: status_to_code) }
      format.json { render(json: iteration_json, status: status_to_code) }
    end
  end

  def iteration_json(opts={})
    {
      result: @iteration.result,
      status: @iteration.status,
      duration: humanized_duration(@iteration.duration),
    }.tap do |response|
      if opts[:html].present?
        response[:html] = ::CommandProposal::CommandFormatter.to_html_lines(@iteration.result)
      end

      if @iteration.started?
        response[:endpoint] = task_runner_path(@task, @iteration)
      end
    end
  end

  def authorize!
    return if can_command?

    render text: "Sorry, you are not authorized to do that."
  end
end
