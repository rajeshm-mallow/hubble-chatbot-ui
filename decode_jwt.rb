#!/usr/bin/env ruby
require 'jwt'
require 'json'

# JWT Decoder for Testing
class JWTDecoder
  def initialize(secret = nil)
    @secret = secret || ENV['JWT_SECRET_KEY'] || 'your-super-secret-jwt-key-here-make-it-long-and-random'
  end

  def decode(token)
    begin
      # Decode without verification first to see the payload
      decoded_payload = JWT.decode(token, nil, false)
      puts "🔓 JWT Token Decoded (without verification):"
      puts "=" * 50
      puts JSON.pretty_generate(decoded_payload[0])
      puts "=" * 50
      
      # Now decode with verification
      verified_payload = JWT.decode(token, @secret, true, { algorithm: 'HS256' })
      puts "✅ JWT Token Verified:"
      puts "=" * 50
      puts JSON.pretty_generate(verified_payload[0])
      puts "=" * 50
      
      # Show token info
      puts "📊 Token Information:"
      puts "- Email: #{verified_payload[0]['email']}"
      puts "- Issued At: #{Time.at(verified_payload[0]['iat'])}"
      puts "- Expires At: #{Time.at(verified_payload[0]['exp'])}"
      puts "- Issuer: #{verified_payload[0]['iss']}"
      puts "- Valid: #{Time.at(verified_payload[0]['exp']) > Time.now ? 'Yes' : 'No'}"
      
    rescue JWT::ExpiredSignature
      puts "❌ JWT Token has expired"
    rescue JWT::DecodeError => e
      puts "❌ JWT Token decode error: #{e.message}"
    rescue => e
      puts "❌ Error: #{e.message}"
    end
  end
  
  def decode_from_file(file_path)
    if File.exist?(file_path)
      token = File.read(file_path).strip
      decode(token)
    else
      puts "❌ File not found: #{file_path}"
    end
  end
end

# Command line usage
if ARGV.length > 0
  decoder = JWTDecoder.new
  
  if ARGV[0] == '--file' && ARGV[1]
    decoder.decode_from_file(ARGV[1])
  else
    decoder.decode(ARGV[0])
  end
else
  puts "Usage:"
  puts "  ruby decode_jwt.rb <jwt_token>"
  puts "  ruby decode_jwt.rb --file <file_with_token>"
  puts ""
  puts "Example:"
  puts "  ruby decode_jwt.rb eyJhbGciOiJIUzI1NiJ9..."
  puts "  ruby decode_jwt.rb --file token.txt"
end
