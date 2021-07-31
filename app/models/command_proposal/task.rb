# has_many :iterations
# text :name
# text :description
# integer :session_type
# datetime :last_executed_at

class ::CommandProposal::Task < ApplicationRecord
  attr_accessor :user

  has_many :iterations
  has_many :ordered_iterations, -> { order(created_at: :desc) }, class_name: "CommandProposal::Iteration"

  scope :search, ->(text) {
    where("name ILIKE :q OR description ILIKE :q", q: "%#{text}%")
  }

  enum session_type: {
    # Task will have multiple iterations that are all essentially the same just with code changes
    task:     0,
    # Console iterations are actually line by line, so order matters
    console:  1,
    # Function iterations are much like tasks
    function: 2,
  }

  after_initialize -> { self.session_type ||= :task }

  delegate :line_count, to: :current_iteration, allow_nil: true
  delegate :code, to: :current_iteration, allow_nil: true
  delegate :result, to: :current_iteration, allow_nil: true
  delegate :status, to: :current_iteration, allow_nil: true

  def approved?
    current_iteration&.approved?
  end

  def first_iteration
    ordered_iterations.last
  end

  def current_iteration
    ordered_iterations.first
  end

  def current_iteration_at
    current_iteration&.completed_at
  end

  def current_iteration_by
    current_iteration&.requester_name
  end

  def started_at
    iterations.minimum(:started_at)
  end

  def completed_at
    iterations.maximum(:completed_at)
  end

  def duration
    return unless started_at.present? && completed_at.present?

    completed_at - started_at
  end

  def code=(new_code)
    iterations.create(code: new_code, requester: user)
  end
end
