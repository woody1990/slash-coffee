class AddActiveToRuns < ActiveRecord::Migration
  def change
    add_column :runs, :active, :boolean, null: false, default: true
  end
end
