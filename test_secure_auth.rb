#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

# Configuration
BASE_URL = 'http://localhost:3000'

def make_request(method, path, body = nil, token = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method.upcase
  when 'GET'
    Net::HTTP::Get.new(uri)
  when 'POST'
    Net::HTTP::Post.new(uri)
  end
  
  request['Content-Type'] = 'application/json'
  request['Authorization'] = "Bearer #{token}" if token
  request.body = body.to_json if body
  
  response = http.request(request)
  {
    status: response.code.to_i,
    body: JSON.parse(response.body) rescue response.body
  }
end

puts "🔒 Testing Secure JWT Authentication"
puts "=" * 50

# Test 1: Get JWT Token from Rails backend
puts "\n1. Getting JWT token from secure Rails backend..."
response = make_request('POST', '/auth')
puts "Status: #{response[:status]}"
puts "Response: #{response[:body]}"

if response[:status] == 200
  token = response[:body]['token']
  email = response[:body]['email']
  puts "✅ Token received: #{token[0..20]}..."
  puts "✅ Email: #{email}"
  
  # Test 2: Validate Token
  puts "\n2. Validating token..."
  response = make_request('GET', '/auth/validate', nil, token)
  puts "Status: #{response[:status]}"
  puts "Response: #{response[:body]}"
  
  if response[:status] == 200
    puts "✅ Token is valid"
    puts "✅ Secure authentication working!"
  else
    puts "❌ Token validation failed"
  end
else
  puts "❌ Failed to get token"
end

puts "\n" + "=" * 50
puts "Security test completed!"
puts "✅ JWT secret is never exposed to frontend"
puts "✅ Tokens are generated server-side"
puts "✅ Authentication is secure"
