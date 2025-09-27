# JWT Decoding Guide for Testing

This guide shows you how to decode JWT tokens locally for testing and debugging.

## 🔧 Local Decoding Tools

### 1. Ruby JWT Decoder

```bash
# Decode a JWT token directly
ruby decode_jwt.rb eyJhbGciOiJIUzI1NiJ9...

# Decode from file
echo "eyJhbGciOiJIUzI1NiJ9..." > token.txt
ruby decode_jwt.rb --file token.txt
```

### 2. Python JWT Decoder

```bash
# Decode a JWT token directly
python decode_jwt.py eyJhbGciOiJIUzI1NiJ9...

# Decode from file
echo "eyJhbGciOiJIUzI1NiJ9..." > token.txt
python decode_jwt.py --file token.txt
```

### 3. Complete Test and Decode

```bash
# Get JWT token from Rails backend and decode it
ruby test_and_decode_jwt.rb
```

This will:
1. Get a JWT token from your Rails backend
2. Decode it locally
3. Validate it with the backend
4. Save the token to `jwt_token.txt` for manual testing

## 🌐 Online JWT Decoders

### 1. jwt.io (Recommended)
- **URL**: https://jwt.io
- **Features**: 
  - Decode without verification
  - Verify with secret key
  - Interactive debugging
  - Multiple algorithms support

### 2. jwtdecode.com
- **URL**: https://jwtdecode.com
- **Features**: Simple decode without verification

### 3. jwt.ms
- **URL**: https://jwt.ms
- **Features**: Microsoft's JWT decoder

## 🔍 Manual Decoding (Base64)

You can also manually decode JWT tokens using base64:

### 1. Split the Token
```bash
# JWT tokens have 3 parts separated by dots
# header.payload.signature
echo "eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6ImFkbWluQGh1YmJsZS1jaGF0Ym90LmNvbSJ9.signature" | cut -d'.' -f1
echo "eyJhbGciOiJIUzI1NiJ9.eyJlbWFpbCI6ImFkbWluQGh1YmJsZS1jaGF0Ym90LmNvbSJ9.signature" | cut -d'.' -f2
```

### 2. Decode Header and Payload
```bash
# Decode header
echo "eyJhbGciOiJIUzI1NiJ9" | base64 -d

# Decode payload
echo "eyJlbWFpbCI6ImFkbWluQGh1YmJsZS1jaGF0Ym90LmNvbSJ9" | base64 -d
```

## 📊 Understanding JWT Structure

### Header
```json
{
  "alg": "HS256",
  "typ": "JWT"
}
```

### Payload
```json
{
  "email": "admin@hubble-chatbot.com",
  "exp": 1234567890,
  "iat": 1234567890,
  "iss": "hubble-chatbot"
}
```

### Signature
- Created using HMAC SHA256
- Uses your JWT secret key
- Verifies token authenticity

## 🧪 Testing Workflow

### 1. Get a Token
```bash
# Start Rails server
rails server

# Get JWT token
curl -X POST http://localhost:3000/auth \
  -H "Content-Type: application/json"
```

### 2. Decode the Token
```bash
# Using our Ruby tool
ruby decode_jwt.rb <your_jwt_token>

# Using our Python tool
python decode_jwt.py <your_jwt_token>

# Using online tool
# Copy token to https://jwt.io
```

### 3. Test Token Validation
```bash
# Test with Rails backend
curl -X GET http://localhost:3000/auth/validate \
  -H "Authorization: Bearer <your_jwt_token>"

# Test with Python backend
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <your_jwt_token>" \
  -d '{"message": "Hello!"}'
```

## 🔐 Security Notes

### ✅ Safe for Testing
- Decoding JWT tokens is safe for testing
- Tokens are designed to be readable
- Only the signature needs the secret key

### ⚠️ Keep Secrets Safe
- Never share your JWT secret key
- Use environment variables for secrets
- Don't commit secrets to version control

### 🛡️ Production Considerations
- Tokens expire after 24 hours
- Use HTTPS in production
- Monitor token usage and validation

## 🚀 Quick Start

1. **Start your servers**:
   ```bash
   rails server
   python python_backend_example.py
   ```

2. **Get and decode a token**:
   ```bash
   ruby test_and_decode_jwt.rb
   ```

3. **Manual testing**:
   ```bash
   # Use the saved token
   ruby decode_jwt.rb $(cat jwt_token.txt)
   ```

4. **Online testing**:
   - Copy token from `jwt_token.txt`
   - Paste into https://jwt.io
   - Enter your JWT secret to verify

Now you can easily decode and test JWT tokens locally! 🎉
