class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  before_action :find_user

  def render_404
    # DPR: this will actually render a 404 page in production
    raise ActionController::RoutingError.new("Not Found")
  end

  def require_login
    current_user = find_user
    if current_user.nil?
      flash[:status] = :error
      flash[:result_text] = "You must be logged in to perform this action."
      redirect_to root_path
    end
    return @login_user
  end

  private

  def find_user
    if session[:user_id]
      @login_user = User.find_by(id: session[:user_id])
    end
  end
end
