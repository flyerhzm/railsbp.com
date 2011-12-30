class AddVisibleToRepository < ActiveRecord::Migration
  def change
    add_column :repositories, :visible, :boolean, default: true, null: false
  end
end
