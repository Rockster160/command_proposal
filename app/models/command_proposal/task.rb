# has_many :iterations
# text :name
# text :description
# integer :session_type
# datetime :last_executed_at

class ::CommandProposal::Task < ApplicationRecord
  has_many :iterations

  enum session_type: {
    # Task will have multiple iterations that are all essentially the same just with code changes
    task:     0,
    # Console iterations are actually line by line, so order matters
    console:  1,
    # Function iterations are much like tasks
    function: 2,
  }

  delegate :line_count, to: :current_iteration, allow_nil: true
  delegate :code, to: :current_iteration, allow_nil: true

  def current_iteration
    iterations.order(created_at: :desc).first
  end

  def current_iteration_at
    current_iteration&.completed_at
  end

  def current_iteration_by
    current_iteration&.requester_name
  end

  def code=(new_code)
    iterations.create(code: new_code)
  end
end
