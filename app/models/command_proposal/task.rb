# has_many :iterations
# text :name
# text :friendly_id
# text :description
# integer :session_type
# datetime :last_executed_at

class ::CommandProposal::Task < ApplicationRecord
  self.table_name = :command_proposal_tasks
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
    # Modules are included in tasks and not run independently
    module:   3,
  }

  validates :name, presence: true

  after_initialize -> { self.session_type ||= :task }
  before_save -> { self.friendly_id = to_param }

  delegate :line_count, to: :current_iteration, allow_nil: true
  delegate :code, to: :current_iteration, allow_nil: true
  delegate :result, to: :current_iteration, allow_nil: true
  delegate :status, to: :primary_iteration, allow_nil: true
  delegate :duration, to: :primary_iteration, allow_nil: true

  def lines
    iterations.order(created_at: :asc).where.not(id: first_iteration.id)
  end

  def to_param
    friendly_id || generate_friendly_id
  end

  def approved?
    primary_iteration&.approved_at?
  end

  def first_iteration
    ordered_iterations.last
  end

  def current_iteration
    ordered_iterations.first
  end

  def primary_iteration
    console? ? first_iteration : current_iteration
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

  def code=(new_code)
    iterations.create(code: new_code, requester: user)
  end

  private

  def reserved_names
    [
      "new",
      "edit",
    ]
  end

  def generate_friendly_id
    return if name.blank?
    temp_id = name.downcase.gsub(/\s+/, "_").gsub(/[^a-z_]/, "")

    loop do
      duplicate_names = self.class.where(friendly_id: temp_id).where.not(id: id)

      return temp_id if duplicate_names.none? && reserved_names.exclude?(temp_id)

      temp_id = "#{temp_id}_#{duplicate_names.count}"
    end
  end
end
