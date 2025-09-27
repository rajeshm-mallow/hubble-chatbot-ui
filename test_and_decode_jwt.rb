#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'
require 'jwt'

# Configuration
BASE_URL = 'http://localhost:3000'

def make_request(method, path, body = nil, headers = {})
  uri = URI("#{BASE_URL}#{path}")
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

def decode_jwt_token(token, secret = nil)
  secret ||= ENV['JWT_SECRET_KEY'] || 'your-super-secret-jwt-key-here-make-it-long-and-random'
  
  begin
    # Decode without verification first
    decoded_payload = JWT.decode(token, nil, false)
    puts "\n🔓 JWT Token Decoded (without verification):"
    puts "=" * 60
    puts JSON.pretty_generate(decoded_payload[0])
    puts "=" * 60
    
    # Now decode with verification
    verified_payload = JWT.decode(token, secret, true, { algorithm: 'HS256' })
    puts "\n✅ JWT Token Verified:"
    puts "=" * 60
    puts JSON.pretty_generate(verified_payload[0])
    puts "=" * 60
    
    # Show token info
    puts "\n📊 Token Information:"
    puts "- Email: #{verified_payload[0]['email']}"
    puts "- Issued At: #{Time.at(verified_payload[0]['iat'])}"
    puts "- Expires At: #{Time.at(verified_payload[0]['exp'])}"
    puts "- Issuer: #{verified_payload[0]['iss']}"
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

puts "🔐 Testing JWT Authentication and Decoding"
puts "=" * 60

# Test 1: Get JWT token from Rails backend
puts "\n1. Getting JWT token from Rails backend..."
response = make_request('POST', '/auth')
puts "Status: #{response[:status]}"
puts "Response: #{response[:body]}"

if response[:status] == 200
  token = response[:body]['token']
  email = response[:body]['email']
  puts "✅ JWT Token received: #{token[0..30]}..."
  puts "✅ Email: #{email}"
  
  # Test 2: Decode the JWT token
  puts "\n2. Decoding JWT token..."
  decoded_payload = decode_jwt_token(token)
  
  if decoded_payload
    puts "✅ JWT token decoded successfully!"
    
    # Test 3: Validate JWT token
    puts "\n3. Validating JWT token with Rails backend..."
    response = make_request('GET', '/auth/validate', nil, { 'Authorization' => "Bearer #{token}" })
    puts "Status: #{response[:status]}"
    puts "Response: #{response[:body]}"
    
    if response[:status] == 200
      puts "✅ JWT token validation successful!"
      
      # Save token to file for manual testing
      File.write('jwt_token.txt', token)
      puts "\n💾 Token saved to 'jwt_token.txt' for manual testing"
      puts "You can now use:"
      puts "  ruby decode_jwt.rb $(cat jwt_token.txt)"
      puts "  python decode_jwt.py $(cat jwt_token.txt)"
    else
      puts "❌ JWT token validation failed"
    end
  else
    puts "❌ Failed to decode JWT token"
  end
else
  puts "❌ Failed to get JWT token"
end

puts "\n" + "=" * 60
puts "JWT testing and decoding completed!"
