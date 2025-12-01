json.extract! receipt, :id, :name, :total_count, :total_value, :created_at, :updated_at
json.url receipt_url(receipt, format: :json)
