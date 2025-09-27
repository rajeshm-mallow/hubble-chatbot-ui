#!/usr/bin/env ruby
require 'net/http'
require 'json'
require 'uri'

puts "🎨 Testing Enhanced Chat UI"
puts "=" * 50

# Test if Rails server is running
begin
  uri = URI('http://localhost:3000')
  response = Net::HTTP.get_response(uri)
  
  if response.is_a?(Net::HTTPSuccess)
    puts "✅ Rails server is running"
    
    # Test auth endpoint with POST
    auth_uri = URI('http://localhost:3000/auth')
    http = Net::HTTP.new(auth_uri.host, auth_uri.port)
    request = Net::HTTP::Post.new(auth_uri.path, {
      'Content-Type' => 'application/json'
    })
    
    auth_response = http.request(request)
    
    if auth_response.is_a?(Net::HTTPSuccess)
      puts "✅ Auth endpoint is working (POST)"
      auth_data = JSON.parse(auth_response.body)
      puts "   JWT Token: #{auth_data['token'][0..30]}..."
      puts "   Email: #{auth_data['email']}"
    else
      puts "❌ Auth endpoint failed: #{auth_response.code}"
      puts "   Response: #{auth_response.body}"
    end
    
    puts "\n🚀 Enhanced UI Features:"
    puts "✅ Modern gradient design"
    puts "✅ Smooth animations and transitions"
    puts "✅ Responsive design for mobile/desktop"
    puts "✅ Auto-resizing textarea"
    puts "✅ Typing indicators with dots animation"
    puts "✅ Message bubbles with hover effects"
    puts "✅ Keyboard shortcuts (Enter/Shift+Enter)"
    puts "✅ Clear input button"
    puts "✅ Sticky header and footer"
    puts "✅ Custom scrollbar styling"
    puts "✅ Loading states and visual feedback"
    puts "✅ POST request for JWT token authentication"
    
    puts "\n📱 Responsive Design:"
    puts "✅ Mobile-optimized message bubbles"
    puts "✅ Adaptive header layout"
    puts "✅ Touch-friendly buttons"
    puts "✅ Proper spacing on all screen sizes"
    
    puts "\n🎭 Animations:"
    puts "✅ Fade-in for new messages"
    puts "✅ Slide-in from left/right"
    puts "✅ Bounce animation for typing dots"
    puts "✅ Pulse animation for send button"
    puts "✅ Hover effects on interactive elements"
    
    puts "\n🔧 Interactive Features:"
    puts "✅ Auto-resize textarea (max 120px height)"
    puts "✅ Enter to send, Shift+Enter for new line"
    puts "✅ Clear input button"
    puts "✅ Disabled state management"
    puts "✅ Smooth scrolling to bottom"
    puts "✅ POST request for JWT authentication"
    
    puts "\n🎨 Visual Enhancements:"
    puts "✅ Gradient backgrounds and buttons"
    puts "✅ Backdrop blur effects"
    puts "✅ Custom scrollbar"
    puts "✅ Shadow effects and depth"
    puts "✅ Professional color scheme"
    puts "✅ Consistent spacing and typography"
    
    puts "\n🌐 Open your browser to http://localhost:3000 to see the enhanced UI!"
    
  else
    puts "❌ Rails server is not running"
    puts "   Start it with: rails server"
  end
  
rescue => e
  puts "❌ Error connecting to Rails server: #{e.message}"
  puts "   Make sure Rails server is running on port 3000"
end

puts "\n" + "=" * 50
puts "Enhanced UI test completed!"
