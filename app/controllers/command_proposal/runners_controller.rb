require_dependency "command_proposal/application_controller"
require "command_proposal/services/command_interpreter"

class ::CommandProposal::RunnersController < ApplicationController
  include ::CommandProposal::PermissionsHelper

  skip_before_action :verify_authenticity_token
  before_action :authorize!, except: :error

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

    5.times do |t|
      sleep 1
      next unless @iteration.reload.complete?

      return render(text: @iteration.reload.result, status: status_to_code)
    end

    render(
      text: "Your task is running. Please come back later. ##{@iteration.id}",
      status: :accepted
    )
  end

  private

  def status_to_code
    case @iteration.status.to_sym
    when :success then :ok
    when :started then :accepted
    when :failed then :unprocessable_entity
    when :stop, :stopped then :bad_request
    else :not_implemented
    end
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
    { args: params.permit!.to_unsafe_h.except(:action, :controller, :task_id) }
  end

  def authorize!
    return if can_command?

    render text: "Sorry, you are not authorized to do that."
  end
end
