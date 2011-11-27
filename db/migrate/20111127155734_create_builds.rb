class CreateBuilds < ActiveRecord::Migration
  def change
    create_table :builds do |t|
      t.integer :warning_count
      t.integer :repository_id
      t.string :aasm_state

      t.timestamps
    end
  end
end
