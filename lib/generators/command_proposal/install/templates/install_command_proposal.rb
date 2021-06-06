class InstallSnitchReporting < ActiveRecord::Migration[5.2]
  def change
    create_table :command_proposal_task do |t|
      # has_many :iterations
      t.integer :session_type # [line, session, function]
      t.datetime :last_executed_at

      t.timestamps
    end

    create_table :command_proposal_iteration do |t|
      # has_many :comments
      t.belongs_to :task
      t.text :args
      t.text :code
      t.text :result
      t.integer :status # [created approved started failed success]
      t.belongs_to :author
      t.belongs_to :approver
      t.datetime :approved_at
      t.datetime :started_at
      t.datetime :completed_at
      t.datetime :stopped_at

      t.timestamps
    end

    create_table :command_proposal_comment do |t|
      t.belongs_to :iteration
      t.integer :line_number
      t.belongs_to :author
      t.text :body

      t.timestamps
    end
  end
end
