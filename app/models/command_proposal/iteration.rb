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

require "command_proposal/service/external_belong"

class ::CommandProposal::Iteration < ApplicationRecord
  include ::CommandProposal::Service::ExternalBelong

  has_many :comments
  belongs_to :task
  external_belongs_to :requester
  external_belongs_to :approver

  enum status: {
    created:  nil,
    approved: 0,
    started:  1,
    failed:   2,
    stopped:  3,
    success:  4,
  }

  delegate :name, to: :task
  delegate :description, to: :task

  def line_count
    return 0 if code.blank?

    code.count("\n")
  end
end
