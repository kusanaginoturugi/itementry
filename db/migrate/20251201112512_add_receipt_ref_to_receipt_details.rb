class AddReceiptRefToReceiptDetails < ActiveRecord::Migration[8.1]
  def change
    add_reference :receipt_details, :receipt, null: false, foreign_key: true
  end
end
