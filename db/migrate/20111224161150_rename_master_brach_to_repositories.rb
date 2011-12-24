class RenameMasterBrachToRepositories < ActiveRecord::Migration
  def up
    remove_column :repositories, :master_branch
    add_column :repositories, :branch, :string, :default => "master", :nil => false
  end

  def down
    remove_column :repositories, :branch
    add_column :repositories, :master_branch, :string
  end
end
