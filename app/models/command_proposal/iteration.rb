# has_many :comments
# belongs_to :task
# text :args
# text :code
# text :result
# integer :status
# belongs_to :author
# belongs_to :approver
# datetime :approved_at
# datetime :started_at
# datetime :completed_at
# datetime :stopped_at

class CommandProposal::Iteration < ApplicationRecord
  has_many :comments
  belongs_to :task
  belongs_to :author
  belongs_to :approver

  enum status: {
    created:  0,
    approved: 1,
    started:  2,
    failed:   3,
    success:  4,
  }
end
