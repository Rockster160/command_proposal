require_dependency "command_proposal/engine_controller"

class ::CommandProposal::TasksController < ::CommandProposal::EngineController
  include ::CommandProposal::ParamsHelper
  helper ::CommandProposal::ParamsHelper
  include ::CommandProposal::PermissionsHelper
  helper ::CommandProposal::PermissionsHelper
  helper ::CommandProposal::IconsHelper

  before_action :authorize_command!, except: :error

  def search
    redirect_to cmd_path(:tasks, current_params)
  end

  def index
    @tasks = ::CommandProposal::Task.includes(:iterations)
    @tasks = @tasks.order(Arel.sql("COALESCE(command_proposal_tasks.last_executed_at, command_proposal_tasks.created_at) DESC"))
    @tasks = @tasks.search(params[:search]) if params[:search].present?
    @tasks = @tasks.by_session(params[:filter])
    @tasks = @tasks.cmd_page(params[:page])
  end

  def show
    @task = ::CommandProposal::Task.find_by!(friendly_id: params[:id])
    if @task.console?
      @lines = @task.lines
      @iteration = @task.first_iteration

      return # Don't execute the rest of the function
    end

    if params.key?(:iteration)
      @iteration = @task.iterations.find(params[:iteration])
    else
      @iteration = @task.current_iteration
    end
  end

  def new
    @task = ::CommandProposal::Task.new
    @task.session_type = params[:session_type] if params[:session_type].in?(::CommandProposal::Task.session_types)

    render "form"
  end

  def edit
    @task = ::CommandProposal::Task.find_by!(friendly_id: params[:id])

    render "form"
  end

  def create
    @task = ::CommandProposal::Task.new(task_params.except(:code))
    @task.user = command_user
    @task.skip_approval = true unless approval_required?

    # Cannot create the iteration until the task is created, so save then update
    if @task.save && @task.update(task_params)
      if @task.console?
        @task.code = nil # Creates a blank iteration to track approval
        redirect_to cmd_path(@task)
      else
        redirect_to cmd_path(:edit, @task)
      end
    else
      # TODO: Display errors
      render "form"
    end
  end

  def update
    @task = ::CommandProposal::Task.find_by!(friendly_id: params[:id])
    @task.user = command_user
    @task.skip_approval = true unless approval_required?

    if @task.update(task_params)
      redirect_to cmd_path(@task)
    else
      # TODO: Display errors
      render "form"
    end
  end

  private

  def task_params
    params.require(:command_proposal_task).permit(
      :name,
      :description,
      :session_type,
      :code,
    )
  end

  def authorize_command!
    return if can_command?

    redirect_to cmd_path(:error, :tasks), alert: "Sorry, you are not authorized to access this page."
  end
end
