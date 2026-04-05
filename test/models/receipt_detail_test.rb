require "test_helper"

class ReceiptDetailTest < ActiveSupport::TestCase
  setup do
    @receipt = receipts(:one)
    @fixed_item = items(:one)    # is_variable_value: false, value: 100
    @variable_item = items(:two) # is_variable_value: true,  value: 200
  end

  def build_detail(item:, value: nil, count: 1)
    @receipt.receipt_details.build(
      item: item,
      item_code: item.item_code,
      item_name: item.name,
      count: count,
      value: value || item.value,
      sum_value: 0,
      refund: 0,
      sum_refund: 0,
      sum_payment: 0
    )
  end

  # --- apply_item_value ---

  test "fixed price item enforces master value" do
    detail = build_detail(item: @fixed_item, value: 999)
    detail.valid?
    assert_equal @fixed_item.value, detail.value
  end

  test "variable price item keeps entered value" do
    detail = build_detail(item: @variable_item, value: 999)
    detail.valid?
    assert_equal 999, detail.value
  end

  # --- assign_item_type_from_code ---

  test "item_type follows item_code prefix" do
    item = Item.create!(item_code: "201", name: "道具", value: 100, item_type: 1, refund: 0, is_variable_value: false)
    detail = build_detail(item: item)
    detail.item_code = "201"
    detail.valid?
    assert_equal 2, detail.item_type
  end

  test "item_type from item when item_code starts with non-digit" do
    # item_code が非数字始まりの場合、コード由来の上書きは行われず item.item_type がそのまま使われる
    detail = build_detail(item: @fixed_item)
    detail.item_code = "A001"
    detail.valid?
    assert_equal @fixed_item.item_type, detail.item_type
  end

  # --- calculate_sum_value ---

  test "sum_value equals count * value" do
    detail = build_detail(item: @fixed_item, count: 3)
    detail.valid?
    assert_equal 3 * @fixed_item.value, detail.sum_value
  end

  test "sum_value is 0 when count is 0" do
    detail = build_detail(item: @fixed_item, count: 0)
    detail.valid?
    assert_equal 0, detail.sum_value
  end

  # --- バリデーション ---

  test "item_code is required" do
    detail = build_detail(item: @fixed_item)
    detail.item_code = ""
    assert_not detail.valid?
    assert detail.errors[:item_code].any?
  end

  test "count must be non-negative integer" do
    detail = build_detail(item: @fixed_item, count: -1)
    assert_not detail.valid?
    assert detail.errors[:count].any?
  end
end
