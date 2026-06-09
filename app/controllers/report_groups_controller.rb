class ReportGroupsController < ApplicationController
  before_action :set_report_group, only: %i[ edit update ]

  def index
    @report_groups = ReportGroup.order(:id)
  end

  def edit
  end

  def update
    if @report_group.update(report_group_params)
      redirect_to report_groups_path, notice: "入金報告グループを更新しました。", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_report_group
    @report_group = ReportGroup.find(params.expect(:id))
  end

  def report_group_params
    params.expect(report_group: [ :name, :code ])
  end
end
