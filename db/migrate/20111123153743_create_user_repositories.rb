class CreateUserRepositories < ActiveRecord::Migration
  def change
    create_table :user_repositories do |t|
      t.integer :user_id
      t.integer :repository_id
    end
  end
end
