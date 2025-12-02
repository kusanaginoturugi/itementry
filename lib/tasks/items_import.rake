require 'csv'

namespace :items do
  desc 'Replace items table with the contents of db/items3.csv'
  task import_items3: :environment do
    csv_path = Rails.root.join('db', 'items3.csv')
    abort "CSV not found: #{csv_path}" unless File.exist?(csv_path)

    rows = CSV.read(csv_path, headers: true)
    required_headers = %w[code name value]
    missing_headers = required_headers - rows.headers.to_a
    abort "CSV must have headers: #{required_headers.join(',')}" if missing_headers.any?

    items = rows.each_with_object([]) do |row, collection|
      next if row.to_h.values.all? { |value| value.to_s.strip.empty? }

      code = row['code']&.strip
      name = row['name']&.strip
      value = row['value']&.strip

      if code.blank? || name.blank? || value.blank?
        warn "Skipping row with missing fields: #{row.to_h.inspect}"
        next
      end

      collection << { item_code: code, name: name, value: Integer(value, 10) }
    end

    Item.transaction do
      ReceiptDetail.delete_all
      Item.delete_all
      items.each { |attrs| Item.create!(attrs) }
    end

    puts "Imported #{items.size} items from #{csv_path}"
  end
end
