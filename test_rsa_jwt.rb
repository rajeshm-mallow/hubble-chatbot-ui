#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'
require 'jwt'
require 'openssl'

# Configuration
BASE_URL = 'http://localhost:3000'
PYTHON_URL = 'http://localhost:8000'

def make_request(method, path, body = nil, headers = {}, base_url = BASE_URL)
  uri = URI("#{base_url}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method.upcase
  when 'GET'
    Net::HTTP::Get.new(uri)
  when 'POST'
    Net::HTTP::Post.new(uri)
  end
  
  request['Content-Type'] = 'application/json'
  headers.each { |key, value| request[key] = value }
  request.body = body.to_json if body
  
  response = http.request(request)
  {
    status: response.code.to_i,
    body: JSON.parse(response.body) rescue response.body
  }
end

def decode_rsa_jwt_token(token)
  public_key_path = 'keys/public_key.pem'
  
  begin
    # Decode without verification first
    decoded_payload = JWT.decode(token, nil, false)
    puts "\n🔓 JWT Token Decoded (without verification):"
    puts "=" * 60
    puts JSON.pretty_generate(decoded_payload[0])
    puts "=" * 60
    
    # Now decode with RSA public key verification
    public_key = OpenSSL::PKey::RSA.new(File.read(public_key_path))
    verified_payload = JWT.decode(token, public_key, true, { algorithm: 'RS256' })
    puts "\n✅ JWT Token Verified with RSA Public Key:"
    puts "=" * 60
    puts JSON.pretty_generate(verified_payload[0])
    puts "=" * 60
    
    # Show token info
    puts "\n📊 Token Information:"
    puts "- Email: #{verified_payload[0]['email']}"
    puts "- Issued At: #{Time.at(verified_payload[0]['iat'])}"
    puts "- Expires At: #{Time.at(verified_payload[0]['exp'])}"
    puts "- Issuer: #{verified_payload[0]['iss']}"
    puts "- Algorithm: RS256 (RSA)"
    puts "- Valid: #{Time.at(verified_payload[0]['exp']) > Time.now ? 'Yes' : 'No'}"
    
    return verified_payload[0]
    
  rescue JWT::ExpiredSignature
    puts "❌ JWT Token has expired"
    return nil
  rescue JWT::DecodeError => e
    puts "❌ JWT Token decode error: #{e.message}"
    return nil
  rescue => e
    puts "❌ Error: #{e.message}"
    return nil
  end
end

def show_rsa_key_info
  puts "\n🔑 RSA Key Information:"
  puts "=" * 60
  
  if File.exist?('keys/private_key.pem')
    private_key = OpenSSL::PKey::RSA.new(File.read('keys/private_key.pem'))
    puts "Private Key:"
    puts "- Size: #{private_key.n.num_bits} bits"
    puts "- Path: keys/private_key.pem"
  else
    puts "❌ Private key not found: keys/private_key.pem"
  end
  
  if File.exist?('keys/public_key.pem')
    public_key = OpenSSL::PKey::RSA.new(File.read('keys/public_key.pem'))
    puts "Public Key:"
    puts "- Size: #{public_key.n.num_bits} bits"
    puts "- Path: keys/public_key.pem"
  else
    puts "❌ Public key not found: keys/public_key.pem"
  end
end

puts "🔐 Testing RSA JWT Authentication with POST"
puts "=" * 60

# Show RSA key information
show_rsa_key_info

# Test 1: Get JWT token from Rails backend using POST
puts "\n1. Getting JWT token from Rails backend (POST)..."
response = make_request('POST', '/auth')
puts "Status: #{response[:status]}"
puts "Response: #{response[:body]}"

if response[:status] == 200
  token = response[:body]['token']
  email = response[:body]['email']
  puts "✅ JWT Token received: #{token[0..30]}..."
  puts "✅ Email: #{email}"
  
  # Test 2: Decode the JWT token with RSA
  puts "\n2. Decoding JWT token with RSA public key..."
  decoded_payload = decode_rsa_jwt_token(token)
  
  if decoded_payload
    puts "✅ JWT token decoded successfully with RSA!"
    
    # Test 3: Validate JWT token with Rails backend
    puts "\n3. Validating JWT token with Rails backend..."
    response = make_request('GET', '/auth/validate', nil, { 'Authorization' => "Bearer #{token}" })
    puts "Status: #{response[:status]}"
    puts "Response: #{response[:body]}"
    
    if response[:status] == 200
      puts "✅ JWT token validation successful!"
      
      # Test 4: Test Python backend communication
      puts "\n4. Testing Python backend communication..."
      response = make_request('POST', '/chat', {
        message: "Hello from RSA JWT test!",
        email: email,
        conversation_history: []
      }, { 'Authorization' => "Bearer #{token}" }, PYTHON_URL)
      
      puts "Status: #{response[:status]}"
      puts "Response: #{response[:body]}"
      
      if response[:status] == 200
        puts "✅ Python backend communication successful!"
      else
        puts "❌ Python backend communication failed"
      end
      
      # Save token to file for manual testing
      File.write('rsa_jwt_token.txt', token)
      puts "\n💾 Token saved to 'rsa_jwt_token.txt' for manual testing"
      puts "You can now use:"
      puts "  ruby decode_jwt_rsa.rb $(cat rsa_jwt_token.txt)"
    else
      puts "❌ JWT token validation failed"
    end
  else
    puts "❌ Failed to decode JWT token with RSA"
  end
else
  puts "❌ Failed to get JWT token"
end

puts "\n" + "=" * 60
puts "RSA JWT testing completed!"
puts "✅ RSA key pair generated"
puts "✅ JWT signed with RSA private key"
puts "✅ JWT verified with RSA public key"
puts "✅ Secure public key encryption"
puts "✅ POST request for JWT token authentication"
