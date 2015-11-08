class AddUserIdToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :user_id, :string, null: false
  end
end
