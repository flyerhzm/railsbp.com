class AddVisibleToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :visible, :boolean, default: false, null: false
  end
end
