class ReceiptsController < ApplicationController
  before_action :set_receipt, only: %i[ show edit update destroy ]
  before_action :set_items, only: %i[ new edit create update ]
  before_action :set_books, only: %i[ index new edit create update ]
  helper_method :sort_column, :sort_direction, :toggle_direction_for

  # GET /receipts or /receipts.json
  def index
    scoped = Receipt
      .includes(:receipt_details)
      .left_joins(:receipt_details)
      .group("receipts.id")
    @selected_book_id = params.key?(:book_id) ? params[:book_id].presence : @current_book&.id
    scoped = scoped.where(book_id: @selected_book_id) if @selected_book_id.present?
    @receipts = scoped.order(order_clause)
    @item_kinds_by_receipt = ReceiptDetail.where(receipt_id: @receipts).group(:receipt_id).distinct.count(:item_code)
    @item_kinds_by_receipt.default = 0
    @item_kinds_total = @item_kinds_by_receipt.values.sum
  end

  # GET /receipts/1 or /receipts/1.json
  def show
  end

  # GET /receipts/new
  def new
    @receipt = Receipt.new(name: Receipt.next_name, book: Book.current)
    @receipt.receipt_details.build
  end

  # GET /receipts/1/edit
  def edit
    @receipt.receipt_details.build if @receipt.receipt_details.empty?
  end

  # POST /receipts or /receipts.json
  def create
    @receipt = Receipt.new(receipt_params)

    respond_to do |format|
      if @receipt.save
        format.html { redirect_to new_receipt_path, notice: "レシートを登録しました。続けて入力できます。" }
        format.json { render :show, status: :created, location: @receipt }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipts/1 or /receipts/1.json
  def update
    respond_to do |format|
      if @receipt.update(receipt_params)
        format.html { redirect_to @receipt, notice: "レシートを更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @receipt }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @receipt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipts/1 or /receipts/1.json
  def destroy
    @receipt.destroy!

    respond_to do |format|
      format.html { redirect_to receipts_path, notice: "レシートを削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt
      @receipt = Receipt.find(params.expect(:id))
    end

    def set_items
      @items = Item.order(:item_code)
    end

    def set_books
      @books = Book.order(:id)
      @current_book = Book.current
    end

    # Only allow a list of trusted parameters through.
  def receipt_params
      params.require(:receipt).permit(
        :name,
        :book_id,
        receipt_details_attributes: %i[
          id item_id item_code item_name count value sum_value _destroy
        ]
      )
    end

    def sort_column
      %w[name item_kinds total_value].include?(params[:sort]) ? params[:sort] : 'name'
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'desc'
    end

    def toggle_direction_for(column)
      return 'asc' unless sort_column == column
      sort_direction == 'asc' ? 'desc' : 'asc'
    end

    def order_clause
      case sort_column
      when 'item_kinds'
        Arel.sql("COUNT(DISTINCT receipt_details.item_code) #{sort_direction}")
      when 'total_value'
        { total_value: sort_direction }
      else
        { name: sort_direction }
      end
    end
end
