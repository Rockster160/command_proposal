require_dependency "command_proposal/application_controller"

class ::CommandProposal::IterationsController < ApplicationController
  include ::CommandProposal::ParamsHelper
  helper ::CommandProposal::ParamsHelper

  layout "application"

  # def index
  #   # @iterations = ::CommandProposal::Iteration.includes(:iterations).order(last_executed_at: :desc)
  # end

  # def show
  #   @iteration = ::CommandProposal::Iteration.find(params[:id])
  #   @task = @iteration.task
  # end
  #
  # def new
  #   # @iteration = ::CommandProposal::Iteration.new
  #
  #   # render partial: "form"
  # end

  def create
    # Verify task is of type `console`
    # if it's the first iteration, create a new session
    # If it's NOT the first iteration, find the existing session
    # If no session exists, return an error
    runner = ::CommandProposal.sessions["task-#{params[:task_id]}"]
    # DELETE ME
    # Should have some logic here checking if approved, if no session has been run prior, etc
    if runner.nil?
      puts "\e[33m[LOGIT]#Creating new runner\e[0m"
      runner = ::CommandProposal::Services::Runner.new
      ::CommandProposal.sessions["task-#{params[:task_id]}"] = runner
    end
    # / DELETE ME

    # Can only be used by console tasks- runs line-by-line functions
    @task = ::CommandProposal::Task.find(params[:task_id])

    @task.update(code: params[:code])
    @iteration = @task.current_iteration
    @iteration.update(status: :approved)

    # sync
    runner.execute(@iteration)

    render json: {
      result: @iteration.result
    }
  end
  #
  # def create
  #   @iteration = ::CommandProposal::Iteration.new(task_params.except(:code))
  #
  #   # Cannot create the iteration until the task is created, save save then update
  #   if @iteration.save && @iteration.update(task_params)
  #     ::CommandProposal.configuration.proposal_callback&.call(@iteration.last_run)
  #
  #     redirect_to @iteration
  #   else
  #     # TODO: Display errors
  #     render partial: "form"
  #   end
  # end

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

#   def index
#     ::CommandProposal::Proposal.warn("Error", some: :data)
#     @reports = ::CommandProposal::Proposal.order("last_occurrence_at DESC NULLS LAST").page(params[:page]).per(params[:per] || 25)
#
#     # set_report_preferences
#     filter_reports
#     # sort_reports
#   end
#
#   def interpret_search
#     redirect_to snitch_reports_path(filter_string: params[:filter_string])
#   end
#
#   def show
#     @report = ::CommandProposal::Proposal.find(params[:id])
#     occurrences = @report.occurrences.order(created_at: :asc)
#     @occurrence = occurrences.find_by(id: params[:occurrence]) || occurrences.last
#     occurrence_ids = occurrences.ids
#     occurrence_idx = occurrence_ids.index(@occurrence.id)
#     @paged_ids = {
#       first: occurrence_idx == 0 ? nil : occurrence_ids.first,
#       prev:  occurrence_idx == 0 ? nil : occurrence_ids[occurrence_idx - 1],
#       next:  occurrence_idx == occurrence_ids.length - 1 ? nil : occurrence_ids[occurrence_idx + 1],
#       last:  occurrence_idx == occurrence_ids.length - 1 ? nil : occurrence_ids.last,
#     }
#     # @formatted_occurrence_data = occurrences.staggered_occurrence_data
#     # @comments = @report.comments.order(created_at: :desc)
#   end
#
#
#   def update
#     @report = ::CommandProposal::Proposal.find(params[:id])
#     # @report.acting_user = current_user
#     @report.update(report_params)
#
#     respond_to do |format|
#       format.html { redirect_to @report }
#       format.json
#     end
#   end
# #
# #   def comment
# #     if @report.comments.create(comment_params.merge(author: current_credential).merge(params.permit(:resolved, :ignored)))
# #       update_report_for(:resolved, comment: false)
# #       update_report_for(:ignored, comment: false)
# #
# #       redirect_to snitch_report_path(@report)
# #     else
# #       redirect_to snitch_report_path(@report), alert: "Failed to comment. Please try again."
# #     end
# #   end
# #
#   private
#
#   def report_params
#     params.require(:snitch_report).permit(
#       :ignored,
#       :resolved
#     )
#   end
# #
# #   def current_snitch_report
# #     @report = CommandProposal::Proposal.find(params[:id])
# #   end
# #
# #   def update_report_for(status, comment: true)
# #     raise "Value not allowed: #{status}" unless status.in?([:resolved, :ignored])
# #
# #     if true_param?(status)
# #       @report.update("#{status}_at": Time.current, "#{status}_by": current_credential)
# #       # @report.comments.create(author: current_credential, message: ">>> Marked as #{status} <<<", skip_notify: true, status => true) if comment
# #     elsif params[status].present?
# #       # @report.comments.create(author: current_credential, message: ">>> Marked as un#{status} <<<", skip_notify: true, status => false) if comment
# #       @report.update("#{status}_at": nil, "#{status}_by": nil)
# #     end
# #   end
# #
# #   def report_params
# #     params.require(:snitch_report).permit(
# #       :source,
# #       :severity,
# #       :assigned_to_id,
# #       :title,
# #       :custom_details
# #     )
# #   end
# #
# #   def comment_params
# #     params.require(:snitch_comment).permit(:message)
# #   end
# #
# #   def set_report_preferences
# #     @filters = begin
# #       preferences = JSON.parse(session[:filters].presence || "{}").symbolize_keys
# #
# #       available_preferences = [:level_tags, :severity_tags, :source_tags, :resolved, :ignored]
# #       available_preferences.each do |pref_key|
# #         pref_val = params[pref_key]
# #         preferences[pref_key] = pref_val if pref_val.present?
# #         preferences.delete(pref_key) if pref_val == "all"
# #       end
# #
# #       session[:filters] = preferences.to_json
# #       preferences
# #     end
# #   end
#   def set_filters
#     @filter_sets = {
#       status: {
#         default: :unresolved,
#         values: [:all, :resolved, :unresolved]
#       },
#       # assignee: {
#       #   default: :any,
#       #   values: [:any, :me, :not_me, :not_assigned]
#       # },
#       log_level: {
#         default: :any,
#         values: [:any] + ::CommandProposal::Proposal.log_levels.keys.map(&:to_sym)
#       },
#       # ignored: {
#       #   default: :not_ignored,
#       #   values: [:all, :ignored, :not_ignored]
#       # }
#     }
#
#     filter_string_from_params
#
#     # @filters = @filter_sets.each_with_object({set_filters: {}}) do |(filter_name, filter_set), filters|
#     #   filters[filter_name] = filter_set[:default]
#     #   filter_in_param = params[filter_name].try(:to_sym)
#     #   next unless filter_in_param && filter_set[:values].include?(filter_in_param)
#     #   filters[filter_name] = filter_in_param
#     #   filters[:set_filters][filter_name] = filter_in_param
#     # end
#   end
#
#   def filter_reports
#     set_filters
#
#     @reports = @reports.resolved if @filters[:status] == :resolved
#     @reports = @reports.unresolved if @filters[:status] == :unresolved
#     @reports = @reports.search(@filters[:search]) if @filters[:search].present?
#     @reports = @reports.by_level(@filters[:log_level]) if @filters[:log_level].present? && @filters[:log_level] != :any
#
#     @reports = @reports.by_tag(*@filters[:tags]) if @filters[:tags].present?
#     # @reports = @reports.by_severity(@filters[:severity_tags]) if @filters[:severity_tags].present?
#     # @reports = @reports.by_source(@filters[:source_tags]) if @filters[:source_tags].present?
#     #
#     # @reports = @filters[:resolved].present? && truthy?(@filters[:resolved]) ? @reports.resolved : @reports.unresolved
#     # @reports = @filters[:ignored].present? && truthy?(@filters[:ignored]) ? @reports.ignored : @reports.unignored
#   end
#
#   def param_safe_value(str)
#     return str unless str.include?(" ")
#
#     "\"#{str}\""
#   end
#   #
#   #   def sort_reports
#   #     order = sort_order || "desc"
#   #     @reports =
#   #     case params[:sort]
#   #     when "count"
#   #       @reports.order("snitch_reporting_snitch_reports.occurrence_count #{order} NULLS LAST, snitch_reporting_snitch_reports.last_occurrence_at DESC NULLS LAST")
#   #     when "last"
#   #       @reports.order("snitch_reporting_snitch_reports.last_occurrence_at #{order} NULLS LAST")
#   #     else
#   #       @reports.order("snitch_reporting_snitch_reports.last_occurrence_at DESC NULLS LAST")
#   #     end
#   #     @reports = @reports.page(params[:page]).per(params[:per])
#   #   end
end
