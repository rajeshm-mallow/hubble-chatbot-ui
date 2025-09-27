#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

# Configuration
BASE_URL = 'http://localhost:3000'
TEST_EMAIL = 'test@example.com'

def make_request(method, path, body = nil, token = nil)
  uri = URI("#{BASE_URL}#{path}")
  http = Net::HTTP.new(uri.host, uri.port)
  
  request = case method.upcase
  when 'GET'
    Net::HTTP::Get.new(uri)
  when 'POST'
    Net::HTTP::Post.new(uri)
  when 'DELETE'
    Net::HTTP::Delete.new(uri)
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

puts "🧪 Testing JWT Authentication API"
puts "=" * 50

# Test 1: Get JWT Token
puts "\n1. Getting JWT token..."
response = make_request('POST', '/auth', { email: TEST_EMAIL })
puts "Status: #{response[:status]}"
puts "Response: #{response[:body]}"

if response[:status] == 200
  token = response[:body]['token']
  puts "✅ Token received: #{token[0..20]}..."
  
  # Test 2: Validate Token
  puts "\n2. Validating token..."
  response = make_request('GET', '/auth/validate', nil, token)
  puts "Status: #{response[:status]}"
  puts "Response: #{response[:body]}"
  
  if response[:status] == 200
    puts "✅ Token is valid"
    
    # Test 3: Create Chat Session
    puts "\n3. Creating chat session..."
    response = make_request('POST', '/chat_sessions', { title: 'Test Chat' }, token)
    puts "Status: #{response[:status]}"
    puts "Response: #{response[:body]}"
    
    if response[:status] == 201
      chat_id = response[:body]['id']
      puts "✅ Chat session created with ID: #{chat_id}"
      
      # Test 4: Send Message
      puts "\n4. Sending message..."
      response = make_request('POST', "/chat_sessions/#{chat_id}/messages", 
                             { message: { content: 'Hello, this is a test message!' } }, token)
      puts "Status: #{response[:status]}"
      puts "Response: #{response[:body]}"
      
      if response[:status] == 201
        puts "✅ Message sent successfully"
        
        # Test 5: Get Messages
        puts "\n5. Getting messages..."
        response = make_request('GET', "/chat_sessions/#{chat_id}/messages", nil, token)
        puts "Status: #{response[:status]}"
        puts "Response: #{response[:body]}"
        
        if response[:status] == 200
          puts "✅ Messages retrieved successfully"
          puts "Total messages: #{response[:body].length}"
        end
      end
    end
  end
else
  puts "❌ Failed to get token"
end

puts "\n" + "=" * 50
puts "Test completed!"
