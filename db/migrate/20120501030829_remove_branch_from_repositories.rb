class RemoveBranchFromRepositories < ActiveRecord::Migration
  def up
    remove_column :repositories, :branch
  end

  def down
    add_column :repositories, :branch, default: "master", null: false
  end
end
