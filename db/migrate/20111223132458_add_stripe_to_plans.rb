class AddStripeToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :identifier, :string
    add_column :plans, :amount, :integer
    add_column :plans, :interval, :string
    add_column :plans, :livemode, :boolean
    add_column :plans, :trial_period_days, :integer
    remove_column :plans, :price
  end
end
