class MoveStripeTokenToUsers < ActiveRecord::Migration
  def up
    add_column :users, :stripe_customer_token, :string
    add_column :users, :plan_id, :integer
    drop_table :subscriptions
  end

  def down
    create_table :subscriptions do |t|
      t.integer  "plan_id"
      t.string   "email"
      t.string   "stripe_customer_token"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "user_id"
    end
    remove_column :users, :plan_id
    remove_column :users, :stripe_customer_token
  end
end
