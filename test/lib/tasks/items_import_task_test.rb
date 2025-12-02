require 'test_helper'
require 'rake'
require 'csv'

class ItemsImportTaskTest < Minitest::Test
  TASK_NAME = 'items:import_items3'

  def setup
    Rails.application.load_tasks unless Rake::Task.task_defined?(TASK_NAME)
    Rake::Task[TASK_NAME].reenable
    clean_tables
  end

  def teardown
    clean_tables
  end

  def test_replaces_items_table_with_db_items3_csv_contents
    csv_path = Rails.root.join('db', 'items3.csv')
    csv_rows = CSV.read(csv_path, headers: true)
    expected_rows = csv_rows.select do |row|
      [row['code'], row['name'], row['value']].all? { |value| value.present? }
    end
    expected_count = expected_rows.length

    Rake::Task[TASK_NAME].invoke

    assert_equal expected_count, Item.count
    first_item = Item.find_by!(item_code: '001')
    assert_equal '招財玉', first_item.name
    assert_equal 10, first_item.value
  end

  private

  def clean_tables
    ReceiptDetail.delete_all
    Receipt.delete_all
    Item.delete_all
  end
end
