require "set"

namespace :receipt_details do
  desc "Sync receipt details from items and recalculate receipts"
  task refresh_from_items: :environment do
    updated_details = 0
    touched_receipt_ids = Set.new

    ReceiptDetail.includes(:item).find_each do |detail|
      item = detail.item || Item.find_by(item_code: detail.item_code)
      next unless item

      detail.assign_attributes(
        item_id: item.id,
        item_code: item.item_code,
        item_name: item.name,
        item_type: item.respond_to?(:item_type) ? item.item_type : nil,
        refund: item.respond_to?(:refund) ? item.refund : nil,
        value: item.value
      )

      if detail.changed?
        if detail.save
          updated_details += 1
          touched_receipt_ids << detail.receipt_id
        else
          puts "Failed to update ReceiptDetail##{detail.id}: #{detail.errors.full_messages.join(', ')}"
        end
      end
    end

    Receipt.where(id: touched_receipt_ids.to_a).find_each do |receipt|
      receipt.save! # triggers total recalculation callbacks
    end

    puts "Updated #{updated_details} receipt details."
    puts "Recalculated #{touched_receipt_ids.size} receipts."
  end
end
