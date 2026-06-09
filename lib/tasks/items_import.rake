require "csv"

namespace :items do
  desc "Replace items table with the contents of db/items.csv"
  task import_items: :environment do
    csv_path = Rails.root.join("db", "items.csv")
    abort "CSV not found: #{csv_path}" unless File.exist?(csv_path)

    rows = CSV.read(csv_path, headers: true)
    report_groups = CSV.read(Rails.root.join("db", "report_groups.csv"), headers: true)
    report_group_rows = CSV.read(Rails.root.join("db", "report_group_id.csv"), headers: true)
    report_group_ids = report_group_rows.each_with_object({}) do |row, mapping|
      code = row["code"].to_s.strip
      mapping[code] ||= row["report_group_id"].to_i
    end
    required_headers = %w[code name value refund]
    missing_headers = required_headers - rows.headers.to_a
    abort "CSV must have headers: #{required_headers.join(',')}" if missing_headers.any?

    items = rows.each_with_object([]) do |row, collection|
      next if row.to_h.values.all? { |value| value.to_s.strip.empty? }

      code = row["code"]&.strip
      name = row["name"]&.strip
      value = row["value"]&.strip
      refund = row["refund"]&.strip
      type = code[0..0]

      if code.blank? || name.blank? || value.blank? || refund.blank? || type.blank?
        warn "Skipping row with missing fields: #{row.to_h.inspect}"
        next
      end

      collection << {
        item_code: code,
        name: name,
        value: Integer(value, 10),
        refund: Integer(refund, 10),
        item_type: type,
        report_group_id: report_group_ids[code]
      }
    end

    Item.transaction do
      ReceiptDetail.delete_all
      Item.delete_all
      report_groups.each do |row|
        report_group = ReportGroup.find_or_initialize_by(id: row["id"].to_i)
        report_group.update!(name: row["name"].to_s.strip, code: row["code"].to_s.strip.presence)
      end
      items.each { |attrs| Item.create!(attrs) }
    end

    puts "Imported #{items.size} items from #{csv_path}"
  end
end
