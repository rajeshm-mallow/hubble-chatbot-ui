class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  # Enable CORS for API requests
  before_action :cors_preflight_check
  after_action :cors_set_access_control_headers

  private

  def cors_set_access_control_headers
  headers['Access-Control-Allow-Origin'] = request.headers['Origin'] || '*' # allows credentials
  headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
  headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-Prototype-Version, Token, Authorization, Content-Type'
  headers['Access-Control-Allow-Credentials'] = 'true' # if using cookies/auth
end

def cors_preflight_check
  if request.method == 'OPTIONS'
    cors_set_access_control_headers
    head :ok
  end
end
end
