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

class ::CommandProposal::Iteration < ApplicationRecord
  include ::CommandProposal::Service::ExternalBelong

  has_many :comments
  belongs_to :task
  external_belongs_to :requester
  external_belongs_to :approver

  enum status: {
    created:  0,
    approved: 1,
    started:  2,
    failed:   3,
    stop:     5, # Running, but told to stop
    stopped:  6,
    success:  7,
  }

  delegate :name, to: :task
  delegate :description, to: :task

  def complete?
    success? || failed? || stopped?
  end

  def pending?
    created?
  end

  def line_count
    return 0 if code.blank?

    code.count("\n")
  end
end
