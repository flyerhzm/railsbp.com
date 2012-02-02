class AddAllowCollaboratorsCountToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :allow_collaborators_count, :integer, default: 0, null: false
  end
end
