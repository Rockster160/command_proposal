# has_many :iterations
# integer :session_type
# datetime :last_executed_at

class CommandProposal::Task < ApplicationRecord
  has_many :iterations

  enum session_type: {
    line:     0,
    task:     1,
    function: 2,
  }
end
