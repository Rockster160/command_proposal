class CreateDummyUser < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name
      t.integer :role, default: 0

      t.timestamps
    end
  end
end
