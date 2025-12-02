class AddItemFieldsToReceiptDetails < ActiveRecord::Migration[7.1]
  def change
    add_column :receipt_details, :item_type, :integer, null: false, default: 1
    add_column :receipt_details, :refund, :integer, null: false, default: 0
    add_column :receipt_details, :sum_refund, :integer, null: false, default: 0
    add_column :receipt_details, :sum_payment, :integer, null: false, default: 0
  end
end
