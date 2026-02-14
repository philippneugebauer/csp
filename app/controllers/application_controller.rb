class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_customer_success_manager, :authenticated?

  before_action :require_authentication

  private
    def authenticated?
      current_customer_success_manager.present?
    end

    def current_customer_success_manager
      @current_customer_success_manager ||= CustomerSuccessManager.find_by(id: session[:customer_success_manager_id])
    end

    def require_authentication
      return if authenticated?

      redirect_to login_path, alert: "Please log in first."
    end
end
