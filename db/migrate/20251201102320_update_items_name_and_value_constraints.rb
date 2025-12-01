class UpdateItemsNameAndValueConstraints < ActiveRecord::Migration[8.1]
  def change
    rename_column :items, :price, :value

    change_column_null :items, :name, false
    change_column_null :items, :value, false
  end
end
