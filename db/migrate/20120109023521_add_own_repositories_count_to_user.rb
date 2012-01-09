class AddOwnRepositoriesCountToUser < ActiveRecord::Migration
  def change
    add_column :users, :own_repositories_count, :integer, default: 0, null: false
  end
end
