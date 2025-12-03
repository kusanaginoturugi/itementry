require "test_helper"

class ReceiptsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @receipt = receipts(:one)
  end

  test "should get index" do
    get receipts_url
    assert_response :success
  end

  test "index shows line counts based on receipt rows" do
    ReceiptDetail.delete_all
    Receipt.delete_all

    receipt = Receipt.create!(name: "50")
    receipt.receipt_details.create!(
      item: items(:one), item_code: items(:one).item_code, item_name: "商品A", count: 1, value: 100, sum_value: 100
    )
    receipt.receipt_details.create!(
      item: items(:one), item_code: items(:one).item_code, item_name: "商品A", count: 3, value: 200, sum_value: 600
    )
    receipt.receipt_details.create!(
      item: items(:two), item_code: items(:two).item_code, item_name: "商品B", count: 2, value: 200, sum_value: 400
    )

    get receipts_url
    assert_response :success

    kind_counts = css_select("tbody tr td:nth-child(2)").map { |td| td.text.strip.to_i }
    assert_equal [ 3 ], kind_counts
    total_kinds = css_select("thead tr.table-secondary th:nth-child(2)").first.text.strip
    assert_equal "3", total_kinds
  end

  test "index can sort by line count descending" do
    ReceiptDetail.delete_all
    Receipt.delete_all

    r1 = Receipt.create!(name: "1")
    r1.receipt_details.create!(item: items(:one), item_code: "001", item_name: "A", count: 1, value: 100, sum_value: 100)
    r1.receipt_details.create!(item: items(:two), item_code: "002", item_name: "B", count: 1, value: 100, sum_value: 100)

    r2 = Receipt.create!(name: "2")
    r2.receipt_details.create!(item: items(:one), item_code: "001", item_name: "A", count: 1, value: 100, sum_value: 100)

    get receipts_url(sort: "line_count", direction: "desc")
    assert_response :success

    names = css_select("table tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal [ "1", "2" ], names
  end

  test "index defaults to current book when no book_id param" do
    Book.update_all(is_use: false)
    books(:public_book).update!(is_use: true)
    ReceiptDetail.delete_all
    Receipt.delete_all

    Receipt.create!(name: "10", book: books(:unclassified))
    Receipt.create!(name: "20", book: books(:public_book))

    get receipts_url
    assert_response :success
    names = css_select("table tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal [ "20" ], names
  end

  test "index can sort by total value ascending" do
    ReceiptDetail.delete_all
    Receipt.delete_all

    r1 = Receipt.create!(name: "1")
    r1.receipt_details.create!(item: items(:one), item_code: "001", item_name: "A", count: 1, value: 100, sum_value: 100)

    r2 = Receipt.create!(name: "2")
    r2.receipt_details.create!(item: items(:one), item_code: "001", item_name: "A", count: 1, value: 300, sum_value: 300)

    get receipts_url(sort: "total_value", direction: "asc")
    assert_response :success

    names = css_select("table tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal [ "1", "2" ], names
  end

  test "should get new" do
    get new_receipt_url
    assert_response :success
  end

  test "new preselects default book" do
    get new_receipt_url
    assert_response :success
    selected = css_select("select[name='receipt[book_id]'] option[selected]").first
    assert_equal books(:unclassified).id.to_s, selected[:value]
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
          book_id: books(:unclassified).id,
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

  test "ignores details without item_code" do
    assert_difference("Receipt.count", 1) do
      assert_difference("ReceiptDetail.count", 1) do
      post receipts_url, params: {
        receipt: {
          name: "30",
          receipt_details_attributes: [
            { item_id: items(:one).id, item_code: "", item_name: "", count: 1, value: 100 },
            { item_id: items(:two).id, item_code: items(:two).item_code, item_name: "商品B", count: 2, value: 200 }
          ]
        }
      }
    end
    end

    receipt = Receipt.order(:created_at).last
    assert_equal 1, receipt.receipt_details.count
    assert_equal 2, receipt.total_count
    assert_equal 400, receipt.total_value
  end

  test "ignores details with zero count" do
    assert_difference("Receipt.count", 1) do
      assert_difference("ReceiptDetail.count", 1) do
      post receipts_url, params: {
        receipt: {
          name: "31",
          receipt_details_attributes: [
            { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 0, value: 100 },
            { item_id: items(:two).id, item_code: items(:two).item_code, item_name: "商品B", count: 3, value: 200 }
          ]
        }
      }
    end
    end

    receipt = Receipt.order(:created_at).last
    assert_equal 1, receipt.receipt_details.count
    assert_equal 3, receipt.total_count
    assert_equal 600, receipt.total_value
  end

  test "rejects non numeric receipt name" do
    assert_no_difference("Receipt.count") do
      post receipts_url, params: {
        receipt: {
          name: "abc",
          book_id: books(:unclassified).id,
          receipt_details_attributes: [
            { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 1, value: 100 }
          ]
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "allows overriding value when item is variable priced" do
    assert_difference([ "Receipt.count", "ReceiptDetail.count" ], 1) do
      post receipts_url, params: {
        receipt: {
          name: "40",
          receipt_details_attributes: [
            { item_id: items(:two).id, item_code: items(:two).item_code, item_name: "商品B", count: 2, value: 999 }
          ]
        }
      }
    end

    receipt = Receipt.last
    detail = receipt.receipt_details.first
    assert_equal 999, detail.value
    assert_equal 1998, receipt.total_value
  end

  test "forces fixed-price items to use master value" do
    assert_difference([ "Receipt.count", "ReceiptDetail.count" ], 1) do
      post receipts_url, params: {
        receipt: {
          name: "41",
          receipt_details_attributes: [
            { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 2, value: 999 }
          ]
        }
      }
    end

    receipt = Receipt.last
    detail = receipt.receipt_details.first
    assert_equal 100, detail.value
    assert_equal 200, receipt.total_value
  end

  test "allows duplicate item codes in a single receipt" do
    assert_difference("Receipt.count", 1) do
      assert_difference("ReceiptDetail.count", 2) do
        post receipts_url, params: {
          receipt: {
            name: "20",
            book_id: books(:unclassified).id,
            receipt_details_attributes: [
              { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 1, value: 100 },
              { item_id: items(:one).id, item_code: items(:one).item_code, item_name: "商品A", count: 2, value: 100 }
            ]
          }
        }
      end
    end

    assert_redirected_to new_receipt_url
    receipt = Receipt.last
    assert_equal 2, receipt.receipt_details.count
    assert_equal 3, receipt.total_count
    assert_equal 300, receipt.total_value
  end

  test "should show receipt" do
    get receipt_url(@receipt)
    assert_response :success
    assert_includes response.body, "登録行数"
    refute_includes response.body, "点数合計"
  end

  test "should get edit" do
    get edit_receipt_url(@receipt)
    assert_response :success
  end

  test "edit shows existing item names" do
    get edit_receipt_url(@receipt)
    assert_response :success
    assert_includes response.body, "商品B"
  end

  test "should update receipt" do
    patch receipt_url(@receipt), params: {
      receipt: {
        name: "999",
        book_id: books(:public_book).id,
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
