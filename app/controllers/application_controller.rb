class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :toggle_direction_for

  def toggle_direction_for(column)
    current_sort = params[:sort]
    current_direction = params[:direction]
    return 'asc' unless current_sort == column
    current_direction == 'asc' ? 'desc' : 'asc'
  end
end
