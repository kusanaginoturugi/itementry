require "rake"

class MaintenanceController < ApplicationController
  def receipt_details_refresh
    load_rake_task
    task = Rake::Task["receipt_details:refresh_from_items"]
    task.reenable
    task.invoke
    redirect_back fallback_location: root_path, notice: "レシート明細を更新しました。"
  rescue StandardError => e
    redirect_back fallback_location: root_path, alert: "更新に失敗しました: #{e.message}"
  end

  private

  def load_rake_task
    return if Rake::Task.task_defined?("receipt_details:refresh_from_items")

    Rails.application.load_tasks
  end
end
