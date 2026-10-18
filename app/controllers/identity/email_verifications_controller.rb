class Identity::EmailVerificationsController < ApplicationController
  skip_before_action :authenticate, only: %i[show create]
  before_action :resume_session, only: :create

  before_action :set_user, only: :show

  def show
    @user.update! verified: true
    redirect_to root_path, notice: "Thank you for verifying your email address"
  end

  def create
    if Current.user
      send_email_verification(Current.user)
      redirect_to root_path, notice: "We sent a verification email to your email address"
    else
      resend_by_email
    end
  end

  private

  # Restore Current.session/user without redirecting, so a signed-in user
  # resending from settings still works while signed-out users may pass an
  # email param instead.
  def resume_session
    if (session_record = Session.find_by_id(cookies.signed[:session_token]))
      Current.session = session_record
    end
  end

  # Signed-out resend (e.g. from the password reset page). Responds
  # identically whether or not the email exists to prevent enumeration.
  # NOTE: no rate limiting on this endpoint yet — add throttling before
  # exposing it to production traffic.
  def resend_by_email
    if (user = User.find_by(email: params[:email])) && !user.verified?
      send_email_verification(user)
    end
    redirect_to new_identity_password_reset_path,
      notice: "If an account exists for that email, a verification email has been sent"
  end

  def set_user
    @user = User.find_by_token_for!(:email_verification, params[:sid])
  rescue
    redirect_to edit_identity_email_path, alert: "That email verification link is invalid"
  end

  def send_email_verification(user)
    UserMailer.with(user: user).email_verification.deliver_later
  end
end
