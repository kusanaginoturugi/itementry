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

  test "locked books are not selectable in index filter" do
    get receipt_details_url
    assert_response :success

    option_values = css_select("select[name='book_id'] option").map { |opt| opt["value"] }.compact
    refute_includes option_values, books(:locked_book).id.to_s
  end

  test "summary can sort by total_value desc" do
    get summary_receipt_details_url(sort: "total_value", direction: "desc")
    assert_response :success
    codes = css_select("tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal codes.sort.reverse, codes
  end

  test "summary defaults to current book when no book_id param" do
    Book.update_all(is_use: false)
    books(:public_book).update!(is_use: true)
    ReceiptDetail.delete_all
    Receipt.delete_all

    r1 = Receipt.create!(name: "10", book: books(:unclassified))
    r1.receipt_details.create!(item: items(:one), item_code: "001", item_name: "A", count: 1, value: 100, sum_value: 100)

    r2 = Receipt.create!(name: "20", book: books(:public_book))
    r2.receipt_details.create!(item: items(:two), item_code: "002", item_name: "B", count: 2, value: 200, sum_value: 400)

    get summary_receipt_details_url
    assert_response :success
    codes = css_select("tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal ["002"], codes
  end

  test "should get summary csv" do
    get summary_receipt_details_url(format: :csv)
    assert_response :success
    assert_equal "text/csv", response.media_type
  end

  test "should get summary by item type with filters" do
    ReceiptDetail.delete_all
    Receipt.delete_all
    Item.delete_all

    item_a = Item.create!(item_code: "100", name: "A", value: 100, item_type: 0, refund: 10)
    item_b = Item.create!(item_code: "200", name: "B", value: 200, item_type: 1, refund: 20)

    r1 = Receipt.create!(name: "10")
    r1.receipt_details.create!(item: item_a, item_code: item_a.item_code, item_name: item_a.name, item_type: item_a.item_type, count: 1, value: 100, sum_value: 100, refund: 10, sum_refund: 10, sum_payment: 90)
    r1.receipt_details.create!(item: item_b, item_code: item_b.item_code, item_name: item_b.name, item_type: item_b.item_type, count: 2, value: 200, sum_value: 400, refund: 20, sum_refund: 40, sum_payment: 360)

    get summary_by_item_type_receipt_details_url(item_type: item_a.item_type)
    assert_response :success

    assert_select "select[name='item_type'] option[selected]", value: item_a.item_type.to_s
    assert_includes response.body, "還付単価"
    assert_includes response.body, "還付合計"
    assert_includes response.body, "支払合計"

    codes = css_select("tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal [item_a.item_code], codes

    refund_values = css_select("tbody tr td:nth-child(5)").map { |td| td.text.strip }
    assert_equal ["10"], refund_values
  end

  test "should render pdf for summary by item type" do
    get summary_by_item_type_receipt_details_url(format: :pdf)
    assert_response :success
    assert_includes ["application/pdf", "text/html"], response.media_type
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
