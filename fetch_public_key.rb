#!/usr/bin/env ruby
require 'net/http'
require 'uri'

puts "🔑 Fetching RSA Public Key - Multiple Methods"
puts "=" * 60

# Method 1: From Rails Backend API
puts "\n1. 📡 Fetching from Rails Backend API..."
begin
  uri = URI('http://localhost:3000/auth/public_key')
  response = Net::HTTP.get_response(uri)
  
  if response.is_a?(Net::HTTPSuccess)
    puts "✅ Successfully fetched from Rails backend:"
    puts response.body
  else
    puts "❌ Failed to fetch from Rails backend: #{response.code} - #{response.body}"
  end
rescue => e
  puts "❌ Error fetching from Rails backend: #{e.message}"
end

# Method 2: From Local File
puts "\n2. 📁 Reading from Local File..."
begin
  if File.exist?('keys/public_key.pem')
    public_key = File.read('keys/public_key.pem')
    puts "✅ Successfully read from local file:"
    puts public_key
  else
    puts "❌ Public key file not found: keys/public_key.pem"
  end
rescue => e
  puts "❌ Error reading local file: #{e.message}"
end

# Method 3: Key Information
puts "\n3. 📊 Key Information..."
begin
  if File.exist?('keys/public_key.pem')
    require 'openssl'
    public_key = OpenSSL::PKey::RSA.new(File.read('keys/public_key.pem'))
    puts "✅ Public Key Details:"
    puts "- Size: #{public_key.n.num_bits} bits"
    puts "- Path: keys/public_key.pem"
    puts "- Algorithm: RSA"
  else
    puts "❌ Public key file not found"
  end
rescue => e
  puts "❌ Error reading key info: #{e.message}"
end

puts "\n" + "=" * 60
puts "Public key fetching methods completed!"
