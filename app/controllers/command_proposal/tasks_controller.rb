require_dependency "command_proposal/application_controller"

class ::CommandProposal::TasksController < ApplicationController
  include ::CommandProposal::ParamsHelper
  helper ::CommandProposal::ParamsHelper
  include ::CommandProposal::PermissionsHelper
  helper ::CommandProposal::PermissionsHelper

  before_action :authorize!, except: :error

  layout "application"

  def search
    redirect_to tasks_path(current_params)
  end

  def index
    @tasks = ::CommandProposal::Task.includes(:iterations).order(last_executed_at: :desc)
    @tasks = @tasks.search(params[:search]) if params[:search].present?
    @tasks = @tasks.where(session_type: params[:filter]) if params[:filter].present?
  end

  def show
    @task = ::CommandProposal::Task.find(params[:id])
    @lines = @task.iterations.includes(:comments).order(created_at: :asc)
    if @task.console?
      @lines = @lines.where.not(id: @task.first_iteration.id)
    end

    if params.key?(:iteration)
      @iteration = @task.iterations.find(params[:iteration])
    else
      @iteration = @task.current_iteration
    end
  end

  def new
    @task = ::CommandProposal::Task.new

    render "form"
  end

  def edit
    @task = ::CommandProposal::Task.find(params[:id])

    render "form"
  end

  def create
    @task = ::CommandProposal::Task.new(task_params.except(:code))

    # Cannot create the iteration until the task is created, so save then update
    if @task.save && @task.update(task_params)
      if @task.console?
        @task.iterations.create(requester: command_user) # Blank iteration to track approval
        redirect_to @task
      else
        redirect_to [:edit, @task]
      end
    else
      # TODO: Display errors
      render "form"
    end
  end

  def update
    @task = ::CommandProposal::Task.find(params[:id])

    if @task.update(task_params)
      redirect_to @task
    else
      # TODO: Display errors
      render "form"
    end
  end

  private

  def task_params
    params.require(:task).permit(
      :name,
      :description,
      :session_type,
      :code,
      :code_html,
    ).tap do |whitelist|
      whitelist[:user] = command_user

      if whitelist.key?(:code_html)
        whitelist[:code] = ::CommandProposal::CommandFormatter.to_text_lines whitelist.delete(:code_html)
      end
    end
  end

  def authorize!
    return if can_command?

    redirect_to main_app.root_path, alert: "Sorry, you are not authorized to access this page."
  end
end
