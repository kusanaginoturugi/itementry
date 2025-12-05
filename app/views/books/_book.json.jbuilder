json.extract! book, :id, :title, :is_lock, :created_at, :updated_at
json.url book_url(book, format: :json)
