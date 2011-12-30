class ResetUserRepositories < ActiveRecord::Migration
  def up
    remove_column :repositories, :user_id
    add_column :user_repositories, :own, :boolean, default: true, null: false
  end

  def down
    remove_column :user_repositories, :own
    add_column :repositories, :user_id, :integer
  end
end
