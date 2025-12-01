class ReceiptDetailsController < ApplicationController
  before_action :set_receipt_detail, only: %i[ show edit update destroy ]

  # GET /receipt_details or /receipt_details.json
  def index
    @receipt_details = ReceiptDetail.all
  end

  # GET /receipt_details/1 or /receipt_details/1.json
  def show
  end

  # GET /receipt_details/new
  def new
    @receipt_detail = ReceiptDetail.new
  end

  # GET /receipt_details/1/edit
  def edit
  end

  # POST /receipt_details or /receipt_details.json
  def create
    @receipt_detail = ReceiptDetail.new(receipt_detail_params)

    respond_to do |format|
      if @receipt_detail.save
        format.html { redirect_to @receipt_detail, notice: "レシート明細を登録しました。" }
        format.json { render :show, status: :created, location: @receipt_detail }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @receipt_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /receipt_details/1 or /receipt_details/1.json
  def update
    respond_to do |format|
      if @receipt_detail.update(receipt_detail_params)
        format.html { redirect_to @receipt_detail, notice: "レシート明細を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @receipt_detail }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @receipt_detail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /receipt_details/1 or /receipt_details/1.json
  def destroy
    @receipt_detail.destroy!

    respond_to do |format|
      format.html { redirect_to receipt_details_path, notice: "レシート明細を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_receipt_detail
      @receipt_detail = ReceiptDetail.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def receipt_detail_params
      params.expect(receipt_detail: [ :receipt_id, :item_id, :item_code, :item_name, :count, :value, :sum_value ])
    end
end
