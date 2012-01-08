class AddAllowPrivacyToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :allow_privacy, :boolean, default: false, null: false
  end
end
