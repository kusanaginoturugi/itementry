require "test_helper"

class ItemTest < ActiveSupport::TestCase
  test "valid item saves successfully" do
    item = Item.new(item_code: "9001", name: "テスト商品", value: 500, is_variable_value: false)
    assert item.valid?
  end

  test "name is required" do
    item = Item.new(item_code: "9001", value: 500)
    assert_not item.valid?
    assert item.errors[:name].any?
  end

  test "value is required" do
    item = Item.new(item_code: "9001", name: "テスト商品")
    assert_not item.valid?
    assert item.errors[:value].any?
  end

  test "item_code is required" do
    item = Item.new(name: "テスト商品", value: 500)
    assert_not item.valid?
    assert item.errors[:item_code].any?
  end

  test "item_code must be numeric only" do
    item = Item.new(item_code: "abc", name: "テスト商品", value: 500)
    assert_not item.valid?
    assert item.errors[:item_code].any?
  end

  test "item_code must be unique" do
    existing = items(:one)
    item = Item.new(item_code: existing.item_code, name: "別商品", value: 300)
    assert_not item.valid?
    assert item.errors[:item_code].any?
  end
end
