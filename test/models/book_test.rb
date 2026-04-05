require "test_helper"

class BookTest < ActiveSupport::TestCase
  test "default returns book with id=1" do
    book = Book.default
    assert_equal 1, book.id
    assert_equal "未分類", book.title
  end

  test "default creates book with id=1 if not exists" do
    ReceiptDetail.delete_all
    Receipt.delete_all
    Book.delete_all
    book = Book.default
    assert_equal 1, book.id
  end

  test "current returns the book with is_use=true" do
    book = Book.current
    assert book.is_use
  end

  test "current returns default if no book is in use" do
    Book.update_all(is_use: false)
    book = Book.current
    assert_equal 1, book.id
  end

  test "use! sets only itself to is_use=true" do
    book = books(:public_book)
    book.use!

    assert book.reload.is_use
    assert_not books(:unclassified).reload.is_use
    assert_not books(:locked_book).reload.is_use
  end

  test "use! is transactional" do
    book = books(:public_book)
    assert_equal 1, Book.where(is_use: true).count
    book.use!
    assert_equal 1, Book.where(is_use: true).count
  end
end
