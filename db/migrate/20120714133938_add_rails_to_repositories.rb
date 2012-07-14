class AddRailsToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :rails, :boolean, nil: true, default: true
  end
end
