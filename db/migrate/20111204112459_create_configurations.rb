class CreateConfigurations < ActiveRecord::Migration
  def change
    create_table :configurations do |t|
      t.string :name
      t.string :description
      t.string :url
      t.integer :category_id
    end
  end
end
