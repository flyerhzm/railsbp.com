class AddGithubUidAndNameAndNicknameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :github_uid, :integer
    add_column :users, :nickname, :string
    add_column :users, :name, :string
  end
end
