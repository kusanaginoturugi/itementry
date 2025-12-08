require "test_helper"
require "rake"

class ReceiptDetailsRefreshTaskTest < ActiveSupport::TestCase
  TASK_NAME = "receipt_details:refresh_from_items"

  def setup
    Rails.application.load_tasks unless Rake::Task.task_defined?(TASK_NAME)
    Rake::Task[TASK_NAME].reenable
    clean_tables
  end

  def teardown
    clean_tables
  end

  def test_refreshes_receipt_details_and_receipts_from_items
    item = Item.create!(item_code: "100", name: "旧名", value: 100, refund: 5, item_type: 0, is_variable_value: false)
    receipt = Receipt.create!(name: "1")
    detail = receipt.receipt_details.create!(
      item: item,
      item_code: "OLD",
      item_name: "古い商品",
      item_type: 9,
      count: 2,
      value: 50,
      refund: 1,
      sum_value: 100,
      sum_refund: 2,
      sum_payment: 98
    )

    item.update!(name: "新しい商品", value: 120, refund: 10, item_type: 3)

    Rake::Task[TASK_NAME].invoke

    detail.reload
    receipt.reload

    assert_equal item.id, detail.item_id
    assert_equal item.item_code, detail.item_code
    assert_equal "新しい商品", detail.item_name
    assert_equal 3, detail.item_type
    assert_equal 120, detail.value
    assert_equal 10, detail.refund
    assert_equal 240, detail.sum_value
    assert_equal 20, detail.sum_refund
    assert_equal 220, detail.sum_payment
    assert_equal 240, receipt.total_value
  end

  def test_skips_variable_value_items
    item = Item.create!(item_code: "200", name: "可変", value: 500, refund: 0, item_type: 1, is_variable_value: true)
    receipt = Receipt.create!(name: "2")
    detail = receipt.receipt_details.create!(
      item: item,
      item_code: "OLD200",
      item_name: "古い道具",
      item_type: 9,
      count: 1,
      value: 300,
      refund: 0,
      sum_value: 300,
      sum_refund: 0,
      sum_payment: 300
    )
    receipt.update!(total_value: 300, total_count: 1)

    item.update!(name: "新しい可変", value: 50, refund: 99, item_type: 4)

    Rake::Task[TASK_NAME].invoke

    detail.reload
    receipt.reload

    # No changes applied
    assert_equal "OLD200", detail.item_code
    assert_equal "古い道具", detail.item_name
    assert_equal 9, detail.item_type
    assert_equal 300, detail.value
    assert_equal 300, receipt.total_value
  end

  private

  def clean_tables
    ReceiptDetail.delete_all
    Receipt.delete_all
    Item.delete_all
  end
end
