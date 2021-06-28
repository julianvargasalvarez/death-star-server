class ApplicationController < ActionController::API
  before_action :require_json!

  protected

  def require_json!
    content_headers = [request.headers['Content-Type'], request.headers['accept']].compact.uniq
    if not content_headers.include?("application/json")
      render nothing: true, status: 204
      return
    end
  end

  def team_signed_in?
    request.headers['Token'].present? && current_team.present?
  end

  def current_team
    Team.where(token: request.headers['Token']).first
  end

  def require_team!
    if not team_signed_in?
      render json: {error: "you are not logged in"}, status: 401
      return
    end
  end
end
