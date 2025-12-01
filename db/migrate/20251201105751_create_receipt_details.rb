class CreateReceiptDetails < ActiveRecord::Migration[8.1]
  def change
    create_table :receipt_details do |t|
      t.integer :item_id
      t.text :item_name
      t.integer :count
      t.integer :value
      t.integer :sum_value

      t.timestamps
    end
  end
end
