class AddItemTypeAndRefundToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :item_type, :integer, null: false, default: 1
    add_column :items, :refund, :integer, null: false, default: 0
  end
end
