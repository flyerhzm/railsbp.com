class CreateParameters < ActiveRecord::Migration
  def change
    create_table :parameters do |t|
      t.string :name
      t.string :kind
      t.string :value
      t.string :description
      t.integer :configuration_id
    end
  end
end
