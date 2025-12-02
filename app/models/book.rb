class Book < ApplicationRecord
  has_many :receipts, dependent: :restrict_with_error

  def self.default
    find_or_create_by!(id: 1) do |book|
      book.title = "未分類"
      book.is_hidden = false
      book.is_use = true
    end
  end

  def self.current
    find_by(is_use: true) || default
  end

  def use!
    transaction do
      self.class.update_all(is_use: false)
      update!(is_use: true)
    end
  end
end
