class ReceiptDetail < ApplicationRecord
  belongs_to :receipt
  belongs_to :item

  before_validation :apply_item_value
  before_validation :calculate_sum_value

  validates :item_code, :item_name, :count, :value, :sum_value, presence: true
  validates :count, :value, :sum_value, :refund, :sum_refund, :sum_payment,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  private

  def apply_item_value
    return unless item
    self.item_type ||= item.item_type if respond_to?(:item_type)
    self.refund = item.refund if respond_to?(:refund)
    return if item.is_variable_value

    self.value = item.value
  end

  def calculate_sum_value
    c = count.to_i
    v = value.to_i
    r = refund.to_i

    self.sum_value = c * v
    self.sum_refund = c * r if respond_to?(:sum_refund=)
    self.sum_payment = sum_value.to_i - sum_refund.to_i if respond_to?(:sum_payment=)
  end
end
