class AddCollaboratorsCountToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :collaborators_count, :integer, default: 0, null: false
  end
end
