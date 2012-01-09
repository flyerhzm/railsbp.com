class AddAllowRepositoriesCountToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :allow_repositories_count, :integer, default: 0, null: false
  end
end
