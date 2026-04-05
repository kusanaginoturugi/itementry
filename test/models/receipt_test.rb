require "test_helper"

class ReceiptTest < ActiveSupport::TestCase
  setup do
    @book = books(:unclassified)
    @item = items(:one)
  end

  # --- next_name ---

  test "next_name returns 1 when no receipts exist" do
    ReceiptDetail.delete_all
    Receipt.delete_all
    assert_equal "1", Receipt.next_name
  end

  test "next_name increments from the largest numeric name in the book" do
    assert_equal "3", Receipt.next_name(book: @book)
  end

  test "next_name ignores non-numeric receipt names" do
    Receipt.create!(name: "99", book: @book)
    assert_equal "100", Receipt.next_name(book: @book)
  end

  test "next_name scopes to the specified book" do
    other_book = books(:public_book)
    assert_equal "1", Receipt.next_name(book: other_book)
  end

  # --- バリデーション ---

  test "name must be numeric only" do
    receipt = Receipt.new(name: "abc", book: @book)
    assert_not receipt.valid?
    assert receipt.errors[:name].any?
  end

  test "assign_default_name sets name on create" do
    receipt = Receipt.create!(book: @book)
    assert_match(/\A\d+\z/, receipt.name)
  end

  test "assign_default_book uses Book.default when book is nil" do
    receipt = Receipt.new
    receipt.valid?
    assert_equal Book.default, receipt.book
  end

  # --- コールバック ---

  test "calculate_totals sums detail counts and values" do
    receipt = Receipt.create!(name: "50", book: @book)
    receipt.receipt_details.create!(
      item: @item, item_code: @item.item_code, item_name: @item.name,
      count: 3, value: @item.value, sum_value: 0, refund: 0, sum_refund: 0, sum_payment: 0
    )
    receipt.receipt_details.create!(
      item: @item, item_code: @item.item_code, item_name: @item.name,
      count: 2, value: @item.value, sum_value: 0, refund: 0, sum_refund: 0, sum_payment: 0
    )
    receipt.save!

    assert_equal 5, receipt.total_count
    assert_equal 5 * @item.value, receipt.total_value
  end

  test "discard_blank_or_zero_details removes details with zero count" do
    receipt = Receipt.create!(name: "51", book: @book)
    receipt.receipt_details.create!(
      item: @item, item_code: @item.item_code, item_name: @item.name,
      count: 0, value: @item.value, sum_value: 0, refund: 0, sum_refund: 0, sum_payment: 0
    )
    receipt.save!

    assert_equal 0, receipt.receipt_details.count
  end

  test "discard_blank_or_zero_details removes details with blank item_code" do
    receipt = Receipt.create!(name: "52", book: @book)
    detail = receipt.receipt_details.build(
      item: @item, item_code: "", item_name: @item.name,
      count: 1, value: @item.value, sum_value: 100, refund: 0, sum_refund: 0, sum_payment: 100
    )
    detail.save(validate: false)
    receipt.save!

    assert_equal 0, receipt.receipt_details.reload.count
  end
end
