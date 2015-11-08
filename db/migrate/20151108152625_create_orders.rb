class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :orderer, null: false
      t.string :item, null: false
      t.integer :run_id, null: false

      t.timestamps null: false
    end
  end
end
