class ReceiptsController < ApplicationController
  before_action :set_receipt, only: %i[ show edit update destroy ]
  before_action :set_items, only: %i[ new edit create update ]

  # GET /receipts or /receipts.json
  def index
    @receipts = Receipt.all
  end

  # GET /receipts/1 or /receipts/1.json
  def show
  end

  # GET /receipts/new
  def new
    @receipt = Receipt.new
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
        format.html { redirect_to @receipt, notice: "レシートを登録しました。" }
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

    # Only allow a list of trusted parameters through.
  def receipt_params
      params.require(:receipt).permit(
        :name,
        receipt_details_attributes: %i[
          id item_id item_code item_name count value sum_value _destroy
        ]
      )
    end
end
