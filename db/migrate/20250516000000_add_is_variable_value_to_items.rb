class AddIsVariableValueToItems < ActiveRecord::Migration[7.1]
  def change
    add_column :items, :is_variable_value, :boolean, null: false, default: false
  end
end
