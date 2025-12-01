class UpdateReceiptDetailsConstraints < ActiveRecord::Migration[8.1]
  def change
    change_column_default :receipt_details, :count, from: nil, to: 0
    change_column_default :receipt_details, :value, from: nil, to: 0
    change_column_default :receipt_details, :sum_value, from: nil, to: 0

    execute <<~SQL.squish
      UPDATE receipt_details
      SET count = 0
      WHERE count IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE receipt_details
      SET value = 0
      WHERE value IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE receipt_details
      SET sum_value = 0
      WHERE sum_value IS NULL
    SQL

    change_column_null :receipt_details, :count, false
    change_column_null :receipt_details, :value, false
    change_column_null :receipt_details, :sum_value, false

    change_column_null :receipt_details, :item_id, false
    add_foreign_key :receipt_details, :items, column: :item_id
    add_index :receipt_details, :item_id
  end
end
