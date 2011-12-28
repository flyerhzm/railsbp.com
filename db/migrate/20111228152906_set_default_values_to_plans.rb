class SetDefaultValuesToPlans < ActiveRecord::Migration
  def up
    change_column_default :plans, :amount, 0
    change_column_default :plans, :livemode, false
    change_column_default :plans, :trial_period_days, 0
  end

  def down
  end
end
