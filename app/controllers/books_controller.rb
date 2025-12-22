class BooksController < ApplicationController
  before_action :set_book, only: %i[ show edit update destroy use ]

  # GET /books or /books.json
  def index
    @books = Book.order(:title)
    @receipt_counts = Receipt.group(:book_id).count
    @receipt_totals = Receipt.group(:book_id).sum(:total_value)
    @current_book = Book.current
  end

  # GET /books/1 or /books/1.json
  def show
  end

  # GET /books/new
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books or /books.json
  def create
    @book = Book.new(book_params)

    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: "帳票を作成しました。" }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1 or /books/1.json
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: "帳票を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1 or /books/1.json
  def destroy
    respond_to do |format|
      begin
        @book.destroy!
        format.html { redirect_to books_path, notice: "帳票を削除しました。", status: :see_other }
        format.json { head :no_content }
      rescue ActiveRecord::DeleteRestrictionError, ActiveRecord::RecordNotDestroyed
        format.html { redirect_to books_path, alert: "レシートが存在するので、帳票の削除は許可できません", status: :see_other }
        format.json { render json: { error: "cannot delete book with receipts" }, status: :unprocessable_entity }
      end
    end
  end

  def use
    @book.use!
    respond_to do |format|
      format.html { redirect_to books_path, notice: "選択した帳票を使用中に設定しました。" }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.expect(book: [ :title, :is_lock, :is_use ])
    end
end
