class AddAllowBuildsCountToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :allow_builds_count, :integer, default: 0, null: false
  end
end
