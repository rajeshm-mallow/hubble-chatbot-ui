class AuthController < ApplicationController
  def create
    # Get email from environment
    email = ENV['USER_EMAIL']
    
    if email.blank?
      render json: { error: 'User email not configured' }, status: :internal_server_error
      return
    end
    
    # Generate JWT token with RSA private key
    token = generate_jwt_token_with_rsa(email)
    
    render json: { 
      token: token, 
      email: email,
      expires_at: 24.hours.from_now.iso8601
    }, status: :ok
  end
  
  def validate
    token = extract_token_from_header
    
    if token && valid_token_with_rsa?(token)
      email = extract_email_from_token_with_rsa(token)
      render json: { 
        valid: true, 
        email: email 
      }, status: :ok
    else
      render json: { 
        valid: false, 
        error: 'Invalid or expired token' 
      }, status: :unauthorized
    end
  end
  
  def public_key
    # Endpoint to get public key for Python backend
    public_key_pem = File.read(public_key_path)
    render plain: public_key_pem, content_type: 'text/plain'
  end
  
  private
  
  def generate_jwt_token_with_rsa(email)
    payload = {
      email: email,
      exp: 24.hours.from_now.to_i,
      iat: Time.current.to_i,
      iss: 'hubble-chatbot'
    }
    
    # Use RSA private key for signing
    private_key = OpenSSL::PKey::RSA.new(File.read(private_key_path))
    JWT.encode(payload, private_key, 'RS256')
  end
  
  def valid_token_with_rsa?(token)
    decoded_token = decode_jwt_token_with_rsa(token)
    return false unless decoded_token
    
    # Check if token is not expired
    exp_time = Time.at(decoded_token['exp'])
    exp_time > Time.current
  end
  
  def extract_email_from_token_with_rsa(token)
    decoded_token = decode_jwt_token_with_rsa(token)
    decoded_token&.dig('email')
  end
  
  def decode_jwt_token_with_rsa(token)
    # Use RSA public key for verification
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_path))
    JWT.decode(token, public_key, true, { algorithm: 'RS256' }).first
  rescue JWT::DecodeError, JWT::ExpiredSignature
    nil
  end
  
  def private_key_path
    ENV['JWT_PRIVATE_KEY_PATH'] || Rails.root.join('keys', 'private_key.pem').to_s
  end
  
  def public_key_path
    ENV['JWT_PUBLIC_KEY_PATH'] || Rails.root.join('keys', 'public_key.pem').to_s
  end
end
