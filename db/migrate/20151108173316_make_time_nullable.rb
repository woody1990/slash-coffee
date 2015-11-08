class MakeTimeNullable < ActiveRecord::Migration
  def change
    change_column_null :runs, :time, true
  end
end
