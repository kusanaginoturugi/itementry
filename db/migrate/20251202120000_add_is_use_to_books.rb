class AddIsUseToBooks < ActiveRecord::Migration[7.1]
  def change
    add_column :books, :is_use, :boolean, null: false, default: false
  end
end
