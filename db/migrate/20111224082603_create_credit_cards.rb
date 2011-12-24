class CreateCreditCards < ActiveRecord::Migration
  def change
    create_table :credit_cards do |t|
      t.string :last4
      t.string :card_type
      t.integer :exp_month
      t.integer :exp_year
      t.integer :user_id

      t.timestamps
    end
  end
end
