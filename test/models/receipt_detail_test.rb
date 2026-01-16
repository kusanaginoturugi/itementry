require "test_helper"

class ReceiptDetailTest < ActiveSupport::TestCase
  test "item_type follows item_code prefix" do
    item = Item.create!(item_code: "201", name: "道具", value: 100, item_type: 1, refund: 0, is_variable_value: false)
    receipt = Receipt.create!(name: "1")

    detail = receipt.receipt_details.create!(
      item: item,
      item_code: "201",
      item_name: "道具",
      count: 1,
      value: 100,
      sum_value: 100,
      refund: 0,
      sum_refund: 0,
      sum_payment: 100
    )

    assert_equal 2, detail.item_type
  end
end
