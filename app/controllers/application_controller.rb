class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def confirm_email
    user = User.find_by!(email_token: params[:token])
    user.update_attributes(email_verified: true, email_token: SecureRandom.hex)
    flash[:notice] = 'Your email has been confirmed'
    redirect_to :root
  end

  def pause_story
    user = User.find_by!(uid: params[:user_uid])
    story = Story.find_by!(user: user, uid: params[:story_uid])
    story.update_attributes(alerts_enabled: false)
    flash[:notice] = 'Alerts have been paused'
    redirect_to :root
  end

  def not_found
    fail ActionController::RoutingError.new('Not Found'), 'Not Found'
  end
end
