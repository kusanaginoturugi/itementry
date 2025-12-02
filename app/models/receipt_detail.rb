class ReceiptDetail < ApplicationRecord
  belongs_to :receipt
  belongs_to :item

  before_validation :apply_item_value
  before_validation :calculate_sum_value

  validates :item_code, :item_name, :count, :value, :sum_value, presence: true
  validates :count, :value, :sum_value, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  private

  def apply_item_value
    return unless item
    return if item.is_variable_value

    self.value = item.value
  end

  def calculate_sum_value
    self.sum_value = count.to_i * value.to_i
  end
end
