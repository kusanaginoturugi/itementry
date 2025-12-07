class ReceiptDetailsController < ApplicationController
  before_action :set_receipt_detail, only: %i[ show edit update destroy ]
  before_action :load_book_filters, only: %i[ index summary summary_by_item_type ]

  # GET /receipt_details or /receipt_details.json
  def index
    scoped = @selected_book_id.present? ? ReceiptDetail.joins(:receipt).where(receipts: { book_id: @selected_book_id }) : ReceiptDetail.all
    @receipt_details = scoped
      .joins(:receipt)
      .select("receipt_details.*, receipts.name AS receipt_name")
      .order(index_order_clause)
  end

  def summary
    scope = ReceiptDetail
    scope = scope.joins(:receipt).where(receipts: { book_id: @selected_book_id }) if @selected_book_id.present?
    @summaries = scope
      .select("item_id, item_code, item_name, SUM(count) AS total_count, SUM(sum_value) AS total_value, SUM(sum_refund) AS total_refund, SUM(sum_payment) AS total_payment")
      .group(:item_id, :item_code, :item_name)
      .order(summary_order_clause)

    respond_to do |format|
      format.html
      format.csv do
        send_data build_csv(@summaries), filename: "receipt_details_summary-#{@current_book.title}-#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.csv"
      end
    end
  end

  def summary_by_item_type
    scope = ReceiptDetail
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
        MAX(refund) AS refund,
        SUM(sum_refund) AS total_sum_refund,
        SUM(sum_payment) AS total_sum_payment
      SQL
      .group(:item_id, :item_code, :item_name, :item_type)
      .order(summary_by_type_order_clause)

    respond_to do |format|
      format.html
      format.pdf do
        response.headers["Content-Type"] = "application/pdf" if Rails.env.test?
        render pdf: "receipt_details_by_item_type-#{Time.zone.now.strftime('%Y%m%d%H%M%S')}",
               template: "receipt_details/summary_by_item_type",
               formats: [:html],
               layout: "application",
               encoding: "UTF-8",
               show_as_html: Rails.env.test?
      end
      format.csv do
        safe_label = helpers.item_type_label(@selected_item_type).presence || "all"
        timestamp = Time.zone.now.strftime('%Y%m%d%H%M%S')
        filename = "receipt_details_by_item_type-#{safe_label}-#{timestamp}.csv"
        send_data build_csv_by_item_type(@summaries), filename: filename
      end
    end
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
      header = %w[item_code item_name total_count total_value total_refund total_payment]
      body = rows.map do |row|
        [
          row.item_code,
          row.item_name,
          row.total_count,
          row.total_value,
          row.total_refund,
          row.total_payment
        ].map { |val| %("#{val.to_s.gsub('"', '""')}") }.join(",")
      end
      ([header.join(",")] + body).join("\n") + "\n"
    end

    def summary_sort_column
      %w[item_code item_name total_count total_value].include?(params[:sort]) ? params[:sort] : 'item_code'
    end

    def index_sort_column
      %w[receipt_name item_code item_name count value sum_value].include?(params[:sort]) ? params[:sort] : "receipt_name"
    end

    def index_sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def index_order_clause
      "#{index_sort_column} #{index_sort_direction}"
    end

    def summary_sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def summary_order_clause
      "#{summary_sort_column} #{summary_sort_direction}"
    end

    def summary_by_type_sort_column
      %w[item_code item_name total_count total_value refund total_sum_refund total_sum_payment].include?(params[:sort]) ? params[:sort] : "item_code"
    end

    def summary_by_type_sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

    def summary_by_type_order_clause
      "#{summary_by_type_sort_column} #{summary_by_type_sort_direction}"
    end

    def load_book_filters
      @books = available_books
      @current_book = @books.find_by(is_use: true)
      @selected_book_id = selected_book_id_from_params(@books, @current_book&.id)
    end

    def available_books
      Book.where(is_lock: false).order(:id)
    end

    def selected_book_id_from_params(books, fallback_id)
      raw_id = params.key?(:book_id) ? params[:book_id].presence : fallback_id
      return unless raw_id.present?
      books.exists?(id: raw_id) ? raw_id : nil
    end

    def build_csv_by_item_type(rows)
      header = %w[item_code item_name total_count total_value refund total_sum_refund total_sum_payment]
      body = rows.map do |row|
        [
          row.item_code,
          row.item_name,
          row.total_count,
          row.total_value,
          row.refund,
          row.total_sum_refund,
          row.total_sum_payment
        ].map { |val| %("#{val.to_s.gsub('"', '""')}") }.join(",")
      end
      ([header.join(",")] + body).join("\n") + "\n"
    end
end
