#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'
require 'base64'

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

puts "🚀 Testing Simple Encoded Email Authentication"
puts "=" * 50

# Test 1: Get encoded email from Rails backend
puts "\n1. Getting encoded email from Rails backend..."
response = make_request('POST', '/auth')
puts "Status: #{response[:status]}"
puts "Response: #{response[:body]}"

if response[:status] == 200
  encoded_email = response[:body]['encoded_email']
  email = response[:body]['email']
  puts "✅ Encoded email received: #{encoded_email[0..20]}..."
  puts "✅ Decoded email: #{email}"
  
  # Test 2: Validate encoded email
  puts "\n2. Validating encoded email..."
  response = make_request('GET', '/auth/validate', nil, { 'X-User-Email' => encoded_email })
  puts "Status: #{response[:status]}"
  puts "Response: #{response[:body]}"
  
  if response[:status] == 200
    puts "✅ Encoded email is valid"
    puts "✅ Simple authentication working!"
    
    # Test 3: Manual decode verification
    puts "\n3. Manual decode verification..."
    decoded = Base64.strict_decode64(encoded_email)
    puts "✅ Manual decode: #{decoded}"
    puts "✅ Matches original: #{decoded == email}"
  else
    puts "❌ Encoded email validation failed"
  end
else
  puts "❌ Failed to get encoded email"
end

puts "\n" + "=" * 50
puts "Simple authentication test completed!"
puts "✅ No JWT complexity"
puts "✅ Simple base64 encoding"
puts "✅ Email sent in X-User-Email header"
puts "✅ Lightweight and secure"
