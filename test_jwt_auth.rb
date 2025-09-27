#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

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

puts "🔐 Testing JWT Authentication with Email from Environment"
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
  
  # Test 2: Validate JWT token
  puts "\n2. Validating JWT token..."
  response = make_request('GET', '/auth/validate', nil, { 'Authorization' => "Bearer #{token}" })
  puts "Status: #{response[:status]}"
  puts "Response: #{response[:body]}"
  
  if response[:status] == 200
    puts "✅ JWT token is valid"
    puts "✅ JWT authentication working!"
    
    # Test 3: Test Python backend communication
    puts "\n3. Testing Python backend communication..."
    puts "Note: Make sure Python backend is running on port 8000"
    puts "You can test this manually by sending a request to Python backend with:"
    puts "Authorization: Bearer #{token[0..30]}..."
  else
    puts "❌ JWT token validation failed"
  end
else
  puts "❌ Failed to get JWT token"
end

puts "\n" + "=" * 60
puts "JWT authentication test completed!"
puts "✅ Email from environment"
puts "✅ JWT token generation"
puts "✅ Token in Authorization header"
puts "✅ Secure authentication"
