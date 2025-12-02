class Book < ApplicationRecord
  has_many :receipts, dependent: :restrict_with_error

  def self.default
    find_or_create_by!(id: 1) do |book|
      book.title = "未分類"
      book.is_hidden = false
    end
  end
end
