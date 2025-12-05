class RemoveIsHiddenFromBooks < ActiveRecord::Migration[8.1]
  def change
    remove_column :books, :is_hidden, :boolean
  end
end
