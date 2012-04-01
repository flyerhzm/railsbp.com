class AddMissingIndexes < ActiveRecord::Migration
  def up
    add_index :builds, :repository_id
    add_index :configurations, :category_id
    add_index :parameters, :configuration_id
    add_index :user_repositories, :user_id
    add_index :user_repositories, :repository_id
  end

  def down
  end
end
