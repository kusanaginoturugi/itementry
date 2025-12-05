class AddIsLockToBooks < ActiveRecord::Migration[8.1]
  def change
    add_column :books, :is_lock, :boolean, default: false, null: false
  end
end
