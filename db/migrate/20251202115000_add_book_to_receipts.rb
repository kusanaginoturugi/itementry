class AddBookToReceipts < ActiveRecord::Migration[7.1]
  class Book < ApplicationRecord
    self.table_name = "books"
  end

  def up
    ensure_default_book
    add_reference :receipts, :book, null: false, default: 1, foreign_key: true
  end

  def down
    remove_reference :receipts, :book, foreign_key: true
  end

  private

  def ensure_default_book
    book = Book.find_or_initialize_by(id: 1)
    book.title = "未分類" if book.title.blank?
    book.is_hidden = false if book.is_hidden.nil?
    book.save!
  end
end
