class RemoveSyncReposFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :sync_repos
  end

  def down
    add_column :users, :sync_repos, :boolean, :default => false, :null => false
  end
end
