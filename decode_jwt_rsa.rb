#!/usr/bin/env ruby
require 'jwt'
require 'json'
require 'openssl'

# RSA JWT Decoder for Testing
class RSAJWTDecoder
  def initialize(private_key_path = nil, public_key_path = nil)
    @private_key_path = private_key_path || 'keys/private_key.pem'
    @public_key_path = public_key_path || 'keys/public_key.pem'
  end
  
  def decode(token)
    begin
      # Decode without verification first to see the payload
      decoded_payload = JWT.decode(token, nil, false)
      puts "�� JWT Token Decoded (without verification):"
      puts "=" * 50
      puts JSON.pretty_generate(decoded_payload[0])
      puts "=" * 50
      
      # Now decode with RSA public key verification
      public_key = OpenSSL::PKey::RSA.new(File.read(@public_key_path))
      verified_payload = JWT.decode(token, public_key, true, { algorithm: 'RS256' })
      puts "✅ JWT Token Verified with RSA Public Key:"
      puts "=" * 50
      puts JSON.pretty_generate(verified_payload[0])
      puts "=" * 50
      
      # Show token info
      puts "📊 Token Information:"
      puts "- Email: #{verified_payload[0]['email']}"
      puts "- Issued At: #{Time.at(verified_payload[0]['iat'])}"
      puts "- Expires At: #{Time.at(verified_payload[0]['exp'])}"
      puts "- Issuer: #{verified_payload[0]['iss']}"
      puts "- Algorithm: RS256 (RSA)"
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
  
  def show_key_info
    puts "🔑 RSA Key Information:"
    puts "=" * 50
    
    if File.exist?(@private_key_path)
      private_key = OpenSSL::PKey::RSA.new(File.read(@private_key_path))
      puts "Private Key:"
      puts "- Size: #{private_key.n.num_bits} bits"
      puts "- Path: #{@private_key_path}"
    else
      puts "❌ Private key not found: #{@private_key_path}"
    end
    
    if File.exist?(@public_key_path)
      public_key = OpenSSL::PKey::RSA.new(File.read(@public_key_path))
      puts "Public Key:"
      puts "- Size: #{public_key.n.num_bits} bits"
      puts "- Path: #{@public_key_path}"
    else
      puts "❌ Public key not found: #{@public_key_path}"
    end
  end
end

# Command line usage
if ARGV.length > 0
  decoder = RSAJWTDecoder.new
  
  case ARGV[0]
  when '--file'
    decoder.decode_from_file(ARGV[1]) if ARGV[1]
  when '--keys'
    decoder.show_key_info
  else
    decoder.decode(ARGV[0])
  end
else
  puts "Usage:"
  puts "  ruby decode_jwt_rsa.rb <jwt_token>"
  puts "  ruby decode_jwt_rsa.rb --file <file_with_token>"
  puts "  ruby decode_jwt_rsa.rb --keys"
  puts ""
  puts "Example:"
  puts "  ruby decode_jwt_rsa.rb eyJhbGciOiJSUzI1NiJ9..."
  puts "  ruby decode_jwt_rsa.rb --file token.txt"
  puts "  ruby decode_jwt_rsa.rb --keys"
end
