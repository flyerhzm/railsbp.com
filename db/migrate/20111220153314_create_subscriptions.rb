class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.integer :plan_id
      t.string :email
      t.string :stripe_customer_token

      t.timestamps
    end
  end
end
