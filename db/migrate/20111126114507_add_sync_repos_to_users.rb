class AddSyncReposToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sync_repos, :boolean, :default => false
  end
end
