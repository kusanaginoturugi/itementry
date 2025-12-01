class AddItemCodeToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :item_code, :text, null: false, default: ""

    reversible do |dir|
      dir.up do
        execute <<~SQL.squish
          UPDATE items
          SET item_code = printf('ITEM%04d', id)
          WHERE item_code IS NULL OR item_code = ''
        SQL
      end
    end

    add_index :items, :item_code, unique: true
  end
end
