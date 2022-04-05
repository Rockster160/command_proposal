# has_many :comments
# belongs_to :task
# text :args
# text :code
# text :result
# integer :status
# belongs_to :requester
# belongs_to :approver
# datetime :approved_at
# datetime :started_at
# datetime :completed_at
# datetime :stopped_at

# ADD: iteration_count?

require_dependency "command_proposal/service/external_belong"
require_dependency "command_proposal/service/json_wrapper"

class ::CommandProposal::Iteration < ApplicationRecord
  self.table_name = :command_proposal_iterations
  serialize :args, ::CommandProposal::Service::JsonWrapper
  include ::CommandProposal::Service::ExternalBelong

  TRUNCATE_COUNT = 2000
  # Also hardcoded in JS: app/assets/javascripts/command_proposal/console.js

  has_many :comments, class_name: "CommandProposal::Comment"
  belongs_to :task, class_name: "CommandProposal::Task"
  external_belongs_to :requester
  external_belongs_to :approver

  enum status: {
    created:    0,
    approved:   1,
    started:    2,
    failed:     3,
    cancelling: 4, # Running, but told to stop
    cancelled:  5,
    success:    6,
    terminated: 7, # Closed via server restart
  }

  scope :cmd_page, ->(page=nil) {
    page = page.presence&.to_i || 1
    per = ::CommandProposal::PAGINATION_PER
    limit(per).offset(per * (page - 1))
  }

  delegate :name, to: :task
  delegate :description, to: :task
  delegate :session_type, to: :task

  def params
    code.scan(/params\[[:\"\'](.*?)[\'\"]?\]/).flatten.uniq
  end

  def brings
    bring_str = code.scan(/bring.*?\n/).flatten.first
    return [] unless bring_str.present?

    ::CommandProposal::Task.module.where(friendly_id: bring_str.scan(/\s+\:(\w+),?/).flatten)
  end

  def primary_iteration?
    task.primary_iteration == self
  end

  def approved?
    super || (session_type == "function" && approved_at?)
  end

  def complete?
    success? || failed? || cancelled? || terminated?
  end

  def pending?
    created?
  end

  def running?
    started? || cancelling?
  end

  def duration
    return unless started_at?

    (completed_at || stopped_at || Time.current) - started_at
  end

  def end_time
    completed_at || stopped_at || Time.current
  end

  def force_reset
    # Debugging method. Should never actually be called.
    update(status: :approved, result: nil, completed_at: nil, stopped_at: nil, started_at: nil)
  end

  def line_count
    return 0 if code.blank?

    code.count("\n")
  end
end
