require "test_helper"
require "securerandom"

class ItemsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @item = items(:one)
  end

  test "should get index" do
    get items_url
    assert_response :success
  end

  test "index lists items ordered by item_code" do
    ReceiptDetail.delete_all
    Item.delete_all
    Item.create!(item_code: "200", name: "三番目の商品", value: 300)
    Item.create!(item_code: "050", name: "一番目の商品", value: 200)
    Item.create!(item_code: "100", name: "二番目の商品", value: 250)

    get items_url
    assert_response :success
    item_codes = css_select("table tbody tr td:first-child").map { |td| td.text.strip }
    assert_equal %w[050 100 200], item_codes
  end

  test "should get new" do
    get new_item_url
    assert_response :success
  end

  test "should create item" do
    assert_difference("Item.count") do
      post items_url, params: { item: { name: "新商品", value: 123, item_code: "9998" } }
    end

    assert_redirected_to item_url(Item.last)
  end

  test "should show item" do
    get item_url(@item)
    assert_response :success
  end

  test "should get edit" do
    get edit_item_url(@item)
    assert_response :success
  end

  test "should update item" do
    patch item_url(@item), params: { item: { name: @item.name, value: @item.value, item_code: "9999" } }
    assert_redirected_to item_url(@item)
  end

  test "should destroy item" do
    assert_difference("Item.count", -1) do
      delete item_url(@item)
    end

    assert_redirected_to items_url
  end
end
