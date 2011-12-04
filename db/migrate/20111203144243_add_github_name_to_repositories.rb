class AddGithubNameToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :github_name, :string
  end
end
