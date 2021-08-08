class InstallCommandProposal < ActiveRecord::Migration[5.0]
  def change
    create_table :command_proposal_tasks do |t|
      # has_many :iterations
      t.text :name
      t.text :friendly_id
      t.text :description
      t.integer :session_type, default: 0 # [task, console, function]
      t.datetime :last_executed_at

      t.timestamps
    end

    create_table :command_proposal_iterations do |t|
      # has_many :comments
      t.belongs_to :task
      t.text :args
      t.text :code
      t.text :result
      t.integer :status, default: 0 # [created approved started failed success]
      t.belongs_to :requester
      t.belongs_to :approver
      t.datetime :approved_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :stopped_at

      t.timestamps
    end

    create_table :command_proposal_comments do |t|
      t.belongs_to :iteration
      t.integer :line_number
      t.belongs_to :author
      t.text :body

      t.timestamps
    end
  end
end
