class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :total
      t.integer :period_start
      t.integer :period_end
      t.integer :user_id
      t.text :raw

      t.timestamps
    end
  end
end
