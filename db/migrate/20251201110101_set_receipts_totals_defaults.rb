class SetReceiptsTotalsDefaults < ActiveRecord::Migration[8.1]
  def change
    change_column_default :receipts, :total_count, from: nil, to: 0
    change_column_default :receipts, :total_value, from: nil, to: 0

    execute <<~SQL.squish
      UPDATE receipts
      SET total_count = 0
      WHERE total_count IS NULL
    SQL

    execute <<~SQL.squish
      UPDATE receipts
      SET total_value = 0
      WHERE total_value IS NULL
    SQL

    change_column_null :receipts, :total_count, false
    change_column_null :receipts, :total_value, false
  end
end
