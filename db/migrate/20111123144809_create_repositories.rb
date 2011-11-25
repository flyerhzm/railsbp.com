class CreateRepositories < ActiveRecord::Migration
  def change
    create_table :repositories do |t|
      t.string :url
      t.string :git_url
      t.string :name
      t.string :description
      t.boolean :private
      t.boolean :fork
      t.string :master_branch
      t.datetime :pushed_at

      t.timestamps
    end
  end
end
