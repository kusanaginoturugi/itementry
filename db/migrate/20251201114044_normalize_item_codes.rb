class NormalizeItemCodes < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE items
      SET item_code = substr(item_code, 5)
      WHERE item_code LIKE 'ITEM%'
    SQL
  end

  def down
    execute <<~SQL.squish
      UPDATE items
      SET item_code = 'ITEM' || item_code
      WHERE item_code NOT LIKE 'ITEM%'
    SQL
  end
end
