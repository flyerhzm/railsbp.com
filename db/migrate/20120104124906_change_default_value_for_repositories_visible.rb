class ChangeDefaultValueForRepositoriesVisible < ActiveRecord::Migration
  def up
    change_column_default :repositories, :visible, false
  end

  def down
    change_column_default :repositories, :visible, true
  end
end
