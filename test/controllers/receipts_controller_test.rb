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

  test "new prepopulates next numeric name" do
    ReceiptDetail.delete_all
    Receipt.delete_all
    Receipt.create!(name: "10")

    get new_receipt_url
    assert_response :success
    name_value = css_select("input[name='receipt[name]']").first[:value]
    assert_equal "11", name_value
  end

  test "new displays item codes ordered by item_code" do
    ReceiptDetail.delete_all
    Receipt.delete_all
    Item.delete_all
    Item.create!(item_code: "300", name: "三番目の商品", value: 300)
    Item.create!(item_code: "010", name: "一番目の商品", value: 100)
    Item.create!(item_code: "200", name: "二番目の商品", value: 200)

    get new_receipt_url
    assert_response :success
    item_codes = css_select(".card.mt-3 .text-monospace.fw-bold").map { |node| node.text.strip }
    assert_equal %w[010 200 300], item_codes
  end

  test "should create receipt" do
    assert_difference("Receipt.count", 1) do
      assert_difference("ReceiptDetail.count", 2) do
      post receipts_url, params: {
        receipt: {
          name: "10",
          receipt_details_attributes: [
            { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 2, value: 100 },
            { item_id: items(:two).id, item_code: items(:two).item_code, item_name: "商品B", count: 1, value: 200 }
          ]
        }
      }
    end
    end

    receipt = Receipt.last
    assert_redirected_to new_receipt_url
    assert_equal 2, receipt.receipt_details.count
    assert_equal 3, receipt.total_count
    assert_equal 400, receipt.total_value
  end

  test "rejects non numeric receipt name" do
    assert_no_difference("Receipt.count") do
      post receipts_url, params: {
        receipt: {
          name: "abc",
          receipt_details_attributes: [
            { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 1, value: 100 }
          ]
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "rejects duplicate item codes in a single receipt" do
    assert_no_difference(["Receipt.count", "ReceiptDetail.count"]) do
      post receipts_url, params: {
        receipt: {
          name: "20",
          receipt_details_attributes: [
            { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 1, value: 100 },
            { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 1, value: 100 }
          ]
        }
      }
    end

    assert_response :unprocessable_entity
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
        name: "999",
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
