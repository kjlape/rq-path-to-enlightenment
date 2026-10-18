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
  # Throttled per email + IP; the throttled response is identical to the
  # success response so the limiter leaks nothing.
  def resend_by_email
    unless resend_throttled?
      if (user = User.find_by(email: params[:email])) && !user.verified?
        send_email_verification(user)
      end
    end
    redirect_to new_identity_password_reset_path,
      notice: "If an account exists for that email, a verification email has been sent"
  end

  RESEND_LIMIT = 3
  RESEND_WINDOW = 3.minutes

  # Cache-counter throttle (Rails 7.1 has no controller-level rate_limit).
  # The sliding-window start time is stored with the count (rather than relying
  # on cache expiry) so the window is exact and testable. Best-effort: a rare
  # read/write race only allows an extra mail, never blocks legitimate traffic.
  def resend_throttled?
    key = "email_verification_resend:#{params[:email].to_s.downcase.strip}:#{request.remote_ip}"
    now = Time.now.to_i
    entry = Rails.cache.read(key)
    if entry.nil? || now - entry[:started_at] >= RESEND_WINDOW
      Rails.cache.write(key, {count: 1, started_at: now}, expires_in: 2 * RESEND_WINDOW)
      false
    else
      Rails.cache.write(key, {count: entry[:count] + 1, started_at: entry[:started_at]}, expires_in: 2 * RESEND_WINDOW)
      entry[:count] + 1 > RESEND_LIMIT
    end
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
