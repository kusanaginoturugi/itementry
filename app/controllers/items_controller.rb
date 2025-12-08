class ItemsController < ApplicationController
  layout "plain", only: :codes
  before_action :set_item, only: %i[ show edit update destroy ]
  helper_method :current_sort_column, :current_sort_direction, :toggle_direction_for

  # GET /items or /items.json
  def index
    @items = Item.order(order_clause)
  end

  def codes
    @items = Item.order(:item_code)
  end

  # GET /items/1 or /items/1.json
  def show
  end

  def lookup
    item = Item.find_by(item_code: params[:item_code])
    if item
      render json: item.slice(:id, :name, :value, :item_code, :is_variable_value)
    else
      head :not_found
    end
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items or /items.json
  def create
    @item = Item.new(item_params)

    respond_to do |format|
      if @item.save
        format.html { redirect_to @item, notice: "道具を登録しました。" }
        format.json { render :show, status: :created, location: @item }
      else
        flash.now[:alert] = duplication_alert(@item)
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /items/1 or /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: "商品を更新しました。", status: :see_other }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1 or /items/1.json
  def destroy
    @item.destroy!

    respond_to do |format|
      format.html { redirect_to items_path, notice: "商品を削除しました。", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def item_params
      params.expect(item: [ :name, :value, :item_code, :is_variable_value, :item_type, :refund ])
    end

    def order_clause
      direction = current_sort_direction == 'desc' ? :desc : :asc
      Item.arel_table[current_sort_column].send(direction)
    end

    def current_sort_column
      %w[item_code name value item_type refund].include?(params[:sort]) ? params[:sort] : 'item_code'
    end

    def current_sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
    end

    def toggle_direction_for(column)
      return 'asc' unless column == current_sort_column
      current_sort_direction == 'asc' ? 'desc' : 'asc'
    end

    def duplication_alert(item)
      return unless item.errors[:item_code].any? { |m| m =~ /has already been taken|重複/ }
      "既存の番号が存在するため、保存できません"
    end
end
