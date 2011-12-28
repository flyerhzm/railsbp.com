class AddAasmStateToUsers < ActiveRecord::Migration
  def change
    add_column :users, :aasm_state, :string
  end
end
