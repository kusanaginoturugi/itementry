class CreateReceipts < ActiveRecord::Migration[8.1]
  def change
    create_table :receipts do |t|
      t.text :name
      t.integer :total_count
      t.integer :total_value

      t.timestamps
    end
  end
end
