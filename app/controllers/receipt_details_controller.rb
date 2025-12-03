class ReceiptDetailsController < ApplicationController
  before_action :set_receipt_detail, only: %i[ show edit update destroy ]

  # GET /receipt_details or /receipt_details.json
  def index
    @books = Book.order(:id)
    @current_book = Book.current
    @selected_book_id = params.key?(:book_id) ? params[:book_id].presence : @current_book&.id
    scoped = @selected_book_id.present? ? ReceiptDetail.joins(:receipt).where(receipts: { book_id: @selected_book_id }) : ReceiptDetail.all
    @receipt_details = scoped
  end

  def summary
    @books = Book.order(:id)
    @current_book = Book.current
    scope = ReceiptDetail
    @selected_book_id = params.key?(:book_id) ? params[:book_id].presence : @current_book&.id
    scope = scope.joins(:receipt).where(receipts: { book_id: @selected_book_id }) if @selected_book_id.present?
    @summaries = scope
      .select("item_id, item_code, item_name, SUM(count) AS total_count, SUM(sum_value) AS total_value")
      .group(:item_id, :item_code, :item_name)
      .order(summary_order_clause)

    respond_to do |format|
      format.html
      format.csv do
        send_data build_csv(@summaries), filename: "receipt_details_summary-#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
      end
    end
  end

  def summary_by_item_type
    @books = Book.order(:id)
    @current_book = Book.current
    scope = ReceiptDetail
    @selected_book_id = params.key?(:book_id) ? params[:book_id].presence : @current_book&.id
    @selected_item_type = params[:item_type].presence
    scope = scope.joins(:receipt).where(receipts: { book_id: @selected_book_id }) if @selected_book_id.present?
    scope = scope.where(item_type: @selected_item_type) if @selected_item_type.present?
    @summaries = scope
      .select(<<~SQL)
        item_id,
        item_code,
        item_name,
        item_type,
        SUM(count) AS total_count,
        SUM(sum_value) AS total_value,
        SUM(refund) AS total_refund,
        SUM(sum_refund) AS total_sum_refund,
        SUM(sum_payment) AS total_sum_payment
      SQL
      .group(:item_id, :item_code, :item_name, :item_type)
      .order(summary_by_type_order_clause)
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
      params.expect(receipt_detail: [ :receipt_id, :item_id, :item_code, :item_name, :item_type, :count, :value, :refund, :sum_value, :sum_refund, :sum_payment ])
    end

    def build_csv(rows)
      header = %w[item_code item_name total_count total_value]
      body = rows.map do |row|
        [
          row.item_code,
          row.item_name,
          row.total_count,
          row.total_value
        ].map { |val| %("#{val.to_s.gsub('"', '""')}") }.join(",")
      end
      ([header.join(",")] + body).join("\n") + "\n"
    end

    def summary_sort_column
      %w[item_code item_name total_count total_value].include?(params[:sort]) ? params[:sort] : 'item_code'
    end

    def summary_sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def summary_order_clause
      "#{summary_sort_column} #{summary_sort_direction}"
    end

    def summary_by_type_sort_column
      %w[item_code item_name total_count total_value total_refund total_sum_refund total_sum_payment].include?(params[:sort]) ? params[:sort] : "item_code"
    end

    def summary_by_type_sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def summary_by_type_order_clause
      "#{summary_by_type_sort_column} #{summary_by_type_sort_direction}"
    end
end
