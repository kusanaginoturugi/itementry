require "test_helper"

class ReceiptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @receipt = receipts(:one)
  end

  test "should get index" do
    get receipts_url
    assert_response :success
  end

  test "should get new" do
    get new_receipt_url
    assert_response :success
  end

  test "should create receipt" do
    assert_difference("Receipt.count", 1) do
      assert_difference("ReceiptDetail.count", 2) do
      post receipts_url, params: {
        receipt: {
          name: "レシートA",
          receipt_details_attributes: [
            { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 2, value: 100 },
            { item_id: items(:two).id, item_code: items(:two).item_code, item_name: "商品B", count: 1, value: 200 }
          ]
        }
      }
    end
    end

    receipt = Receipt.last
    assert_redirected_to receipt_url(receipt)
    assert_equal 2, receipt.receipt_details.count
    assert_equal 3, receipt.total_count
    assert_equal 400, receipt.total_value
  end

  test "should show receipt" do
    get receipt_url(@receipt)
    assert_response :success
  end

  test "should get edit" do
    get edit_receipt_url(@receipt)
    assert_response :success
  end

  test "should update receipt" do
    patch receipt_url(@receipt), params: {
      receipt: {
        name: "更新後レシート",
        receipt_details_attributes: [
          { id: @receipt.receipt_details.first.id, item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 3, value: 100 }
        ]
      }
    }
    assert_redirected_to receipt_url(@receipt)
    @receipt.reload
    assert_equal 3, @receipt.total_count
    assert_equal 300, @receipt.total_value
  end

  test "should destroy receipt" do
    assert_difference("Receipt.count", -1) do
      delete receipt_url(@receipt)
    end

    assert_redirected_to receipts_url
  end
end
