class ReceiptsController < ApplicationController
  before_action :set_receipt, only: %i[ show edit update destroy ]
  before_action :set_items, only: %i[ new edit create update ]
  before_action :set_books, only: %i[ index new edit create update ]

  # GET /receipts or /receipts.json
  def index
    scoped = Receipt.includes(:receipt_details)
    scoped = scoped.where(book_id: params[:book_id]) if params[:book_id].present?
    @receipts = scoped
    @item_kinds_by_receipt = ReceiptDetail.where(receipt_id: @receipts).group(:receipt_id).distinct.count(:item_code)
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
end
