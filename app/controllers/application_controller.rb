class ApplicationController < ActionController::Base
  default_form_builder ApplicationFormBuilder

  before_action :set_current_request_details
  before_action :authenticate

  private

  def authenticate
    if (session_record = Session.find_by_id(cookies.signed[:session_token]))
      Current.session = session_record
    else
      redirect_to sign_in_path
    end
  end

  def set_current_request_details
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
  end

  def require_sudo
    unless Current.session.sudo?
      redirect_to new_sessions_sudo_path(proceed_to_url: request.original_url)
    end
  end

  def require_admin
    unless Current.user&.admin?
      redirect_to root_url, alert: "You are not authorized to modify content."
    end
  end
end
