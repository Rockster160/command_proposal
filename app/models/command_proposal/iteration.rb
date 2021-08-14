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

require "command_proposal/service/external_belong"
require "command_proposal/service/json_wrapper"

class ::CommandProposal::Iteration < ApplicationRecord
  serialize :args, ::CommandProposal::Service::JSONWrapper
  include ::CommandProposal::Service::ExternalBelong

  has_many :comments
  belongs_to :task
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
  }

  delegate :name, to: :task
  delegate :description, to: :task

  def params
    code.scan(/params\[[:\"\'](.*?)[\'\"]?\]/).flatten
  end

  def complete?
    success? || failed? || cancelled?
  end

  def pending?
    created?
  end

  def duration
    return unless started_at?

    (completed_at || stopped_at || Time.current) - started_at
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
