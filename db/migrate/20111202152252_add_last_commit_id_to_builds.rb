class AddLastCommitIdToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :last_commit_id, :string
  end
end
