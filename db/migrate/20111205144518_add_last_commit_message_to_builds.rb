class AddLastCommitMessageToBuilds < ActiveRecord::Migration
  def change
    add_column :builds, :last_commit_message, :text
  end
end
