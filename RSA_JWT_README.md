# RSA JWT Authentication - Public Key Encryption

This implementation uses **RSA public key encryption** for JWT authentication, providing enhanced security over shared secret approaches.

## 🔐 RSA JWT Security Features

- **RSA Key Pair**: 2048-bit RSA private/public key pair
- **Private Key Signing**: Rails backend signs JWT tokens with RSA private key
- **Public Key Verification**: Python backend verifies tokens with RSA public key
- **No Shared Secrets**: No secret keys to manage or distribute
- **Enhanced Security**: Much more secure than HMAC-based JWT

## 🏗️ Architecture

### Key Distribution
```
Rails Backend (Private Key) → Signs JWT tokens
Python Backend (Public Key) → Verifies JWT tokens
```

### Authentication Flow
```
1. Frontend → Rails: "Give me a JWT token"
2. Rails → Frontend: JWT token (signed with private key)
3. Frontend → Python: JWT token in Authorization header
4. Python → Frontend: Response (verified with public key)
```

## 📁 File Structure

```
keys/
├── private_key.pem    # RSA private key (Rails backend only)
└── public_key.pem     # RSA public key (Python backend)

app/controllers/
└── auth_controller.rb # JWT signing with RSA private key

python_backend_example.py # JWT verification with RSA public key
```

## 🚀 Setup

### 1. Generate RSA Keys (Already Done)
```bash
# Private key (Rails backend)
openssl genrsa -out keys/private_key.pem 2048

# Public key (Python backend)
openssl rsa -in keys/private_key.pem -pubout -out keys/public_key.pem
```

### 2. Environment Configuration
```env
# User Email
USER_EMAIL=admin@hubble-chatbot.com

# Python Backend URL
PYTHON_BACKEND_URL=http://localhost:8000

# RSA Key Paths (optional)
JWT_PRIVATE_KEY_PATH=keys/private_key.pem
JWT_PUBLIC_KEY_PATH=keys/public_key.pem
```

### 3. Install Dependencies
```bash
# Rails dependencies
bundle install

# Python dependencies
pip install -r requirements.txt
```

### 4. Start Servers
```bash
# Start Rails server
rails server

# Start Python backend
python python_backend_example.py
```

## 🔧 Testing Tools

### 1. Complete RSA JWT Test
```bash
ruby test_rsa_jwt.rb
```

This will:
- Show RSA key information
- Get JWT token from Rails backend
- Decode token with RSA public key
- Validate token with Rails backend
- Test Python backend communication
- Save token for manual testing

### 2. Manual JWT Decoding
```bash
# Decode JWT token with RSA
ruby decode_jwt_rsa.rb <jwt_token>

# Decode from file
ruby decode_jwt_rsa.rb --file rsa_jwt_token.txt

# Show RSA key information
ruby decode_jwt_rsa.rb --keys
```

### 3. API Testing
```bash
# Get JWT token
curl -X POST http://localhost:3000/auth

# Validate token
curl -X GET http://localhost:3000/auth/validate \
  -H "Authorization: Bearer <jwt_token>"

# Get public key
curl -X GET http://localhost:3000/auth/public_key

# Test Python backend
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <jwt_token>" \
  -d '{"message": "Hello!"}'
```

## 🔐 Security Benefits

### ✅ **Enhanced Security**
- **RSA Encryption**: Much stronger than HMAC
- **Key Separation**: Private key never leaves Rails backend
- **Public Key Distribution**: Safe to share public key
- **No Shared Secrets**: Eliminates secret key management

### ✅ **Scalability**
- **Multiple Backends**: Can verify tokens with same public key
- **Key Rotation**: Easy to rotate keys without affecting all services
- **Microservices**: Perfect for distributed systems

### ✅ **Compliance**
- **Industry Standard**: RSA is widely accepted
- **Audit Trail**: Clear key usage and verification
- **Best Practices**: Follows security best practices

## 📊 JWT Token Structure

### Header
```json
{
  "alg": "RS256",
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
- Created using RSA-SHA256
- Uses Rails backend's private key
- Verified using public key

## 🔄 Key Management

### Key Generation
```bash
# Generate new 2048-bit RSA key pair
openssl genrsa -out keys/private_key.pem 2048
openssl rsa -in keys/private_key.pem -pubout -out keys/public_key.pem
```

### Key Distribution
- **Private Key**: Keep secure on Rails backend only
- **Public Key**: Safe to distribute to Python backends
- **Key Rotation**: Generate new keys and update backends

### Key Security
- **Private Key**: Never commit to version control
- **Public Key**: Can be committed (it's public)
- **Permissions**: Set appropriate file permissions
- **Backup**: Secure backup of private key

## 🚀 Production Deployment

### 1. Key Management
- Use secure key management service
- Rotate keys regularly
- Monitor key usage

### 2. Security
- Use HTTPS for all communication
- Set proper file permissions
- Monitor authentication failures

### 3. Monitoring
- Log JWT token usage
- Monitor key verification failures
- Track authentication patterns

## 🔍 Troubleshooting

### Common Issues

1. **Key Not Found**
   - Check file paths in environment variables
   - Ensure keys directory exists
   - Verify file permissions

2. **Token Verification Failed**
   - Check if public key matches private key
   - Verify token hasn't expired
   - Check algorithm (should be RS256)

3. **Python Backend Can't Get Public Key**
   - Ensure Rails backend is running
   - Check public key endpoint
   - Verify network connectivity

### Debug Commands
```bash
# Check key information
ruby decode_jwt_rsa.rb --keys

# Test complete flow
ruby test_rsa_jwt.rb

# Manual token decoding
ruby decode_jwt_rsa.rb <token>
```

## 🎯 Benefits Over HMAC

| Feature | HMAC (Shared Secret) | RSA (Public Key) |
|---------|---------------------|------------------|
| Security | Good | Excellent |
| Key Management | Complex | Simple |
| Scalability | Limited | High |
| Key Distribution | Risky | Safe |
| Compliance | Basic | Advanced |

The RSA implementation provides **enterprise-grade security** with **simple key management**! 🚀
