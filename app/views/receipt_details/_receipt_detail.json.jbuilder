json.extract! receipt_detail, :id, :item_id, :item_name, :count, :value, :sum_value, :created_at, :updated_at
json.url receipt_detail_url(receipt_detail, format: :json)
