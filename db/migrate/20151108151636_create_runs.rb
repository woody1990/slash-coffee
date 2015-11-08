class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.string :team_id, null: false
      t.string :channel_id, null: false
      t.string :runner, null: false
      t.integer :time, null: false

      t.timestamps null: false
    end
  end
end
