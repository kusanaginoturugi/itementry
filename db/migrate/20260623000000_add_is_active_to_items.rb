class AddIsActiveToItems < ActiveRecord::Migration[8.1]
  def change
    add_column :items, :is_active, :boolean, null: false, default: true
  end
end
