class AddOrderIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :orderer_id, :string
    change_column_null :orders, :orderer_id, true
  end
end
