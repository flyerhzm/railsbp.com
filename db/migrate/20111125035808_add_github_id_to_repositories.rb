class AddGithubIdToRepositories < ActiveRecord::Migration
  def change
    add_column :repositories, :github_id, :integer
  end
end
