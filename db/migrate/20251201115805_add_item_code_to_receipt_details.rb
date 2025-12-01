class AddItemCodeToReceiptDetails < ActiveRecord::Migration[8.1]
  def change
    add_column :receipt_details, :item_code, :text, null: false, default: ""
    add_index :receipt_details, :item_code
  end
end
