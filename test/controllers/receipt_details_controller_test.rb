require "test_helper"

class ReceiptDetailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @receipt_detail = receipt_details(:one)
  end

  test "should get index" do
    get receipt_details_url
    assert_response :success
  end

  test "should get summary" do
    get summary_receipt_details_url
    assert_response :success
  end

  test "summary can sort by total_value desc" do
    get summary_receipt_details_url(sort: "total_value", direction: "desc")
    assert_response :success
    codes = css_select("tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal codes.sort.reverse, codes
  end

  test "should get summary csv" do
    get summary_receipt_details_url(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.media_type
  end

  test "should get new" do
    get new_receipt_detail_url
    assert_response :success
  end

  test "should create receipt_detail" do
    assert_difference("ReceiptDetail.count") do
      post receipt_details_url, params: {
        receipt_detail: {
          receipt_id: receipts(:one).id,
          item_id: items(:one).id,
          item_code: "0001",
          item_name: "追加",
          count: 2,
          value: 10,
          sum_value: 20
        }
      }
    end

    assert_redirected_to receipt_detail_url(ReceiptDetail.last)
  end

  test "should show receipt_detail" do
    get receipt_detail_url(@receipt_detail)
    assert_response :success
  end

  test "should get edit" do
    get edit_receipt_detail_url(@receipt_detail)
    assert_response :success
  end

  test "should update receipt_detail" do
    patch receipt_detail_url(@receipt_detail), params: {
      receipt_detail: {
        receipt_id: receipts(:one).id,
        item_id: items(:two).id,
        item_name: "修正",
        count: 3,
        value: 5,
        sum_value: 15
      }
    }
    assert_redirected_to receipt_detail_url(@receipt_detail)
  end

  test "should destroy receipt_detail" do
    assert_difference("ReceiptDetail.count", -1) do
      delete receipt_detail_url(@receipt_detail)
    end

    assert_redirected_to receipt_details_url
  end
end
