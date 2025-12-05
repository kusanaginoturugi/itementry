require "test_helper"

class BooksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @book = books(:public_book)
  end

  test "should get index" do
    get books_url
    assert_response :success
  end

  test "should select book as current" do
    patch use_book_url(@book)
    assert_redirected_to books_url
    assert_predicate @book.reload, :is_use?
    assert_equal false, books(:unclassified).reload.is_use?
  end

  test "should get new" do
    get new_book_url
    assert_response :success
  end

  test "should create book" do
    assert_difference("Book.count") do
      post books_url, params: { book: { is_lock: true, title: "新しい台帳" } }
    end

    created_book = Book.last
    assert_redirected_to book_url(created_book)
    assert_predicate created_book, :is_lock?
  end

  test "should show book" do
    get book_url(@book)
    assert_response :success
  end

  test "should get edit" do
    get edit_book_url(@book)
    assert_response :success
  end

  test "should update book" do
    patch book_url(@book), params: { book: { is_lock: true, title: "更新後台帳" } }
    assert_redirected_to book_url(@book)
    assert_predicate @book.reload, :is_lock?
  end

  test "should destroy book" do
    assert_difference("Book.count", -1) do
      delete book_url(@book)
    end

    assert_redirected_to books_url
  end
end
