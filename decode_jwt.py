#!/usr/bin/env python3
"""
JWT Decoder for Testing
Decodes JWT tokens locally for testing and debugging
"""

import jwt
import json
import sys
import os
from datetime import datetime

class JWTDecoder:
    def __init__(self, secret=None):
        self.secret = secret or os.getenv('JWT_SECRET_KEY', 'your-super-secret-jwt-key-here-make-it-long-and-random')
    
    def decode(self, token):
        try:
            # Decode without verification first to see the payload
            decoded_payload = jwt.decode(token, options={"verify_signature": False})
            print("🔓 JWT Token Decoded (without verification):")
            print("=" * 50)
            print(json.dumps(decoded_payload, indent=2))
            print("=" * 50)
            
            # Now decode with verification
            verified_payload = jwt.decode(token, self.secret, algorithms=['HS256'])
            print("✅ JWT Token Verified:")
            print("=" * 50)
            print(json.dumps(verified_payload, indent=2))
            print("=" * 50)
            
            # Show token info
            print("📊 Token Information:")
            print(f"- Email: {verified_payload['email']}")
            print(f"- Issued At: {datetime.fromtimestamp(verified_payload['iat'])}")
            print(f"- Expires At: {datetime.fromtimestamp(verified_payload['exp'])}")
            print(f"- Issuer: {verified_payload['iss']}")
            print(f"- Valid: {'Yes' if datetime.fromtimestamp(verified_payload['exp']) > datetime.now() else 'No'}")
            
        except jwt.ExpiredSignatureError:
            print("❌ JWT Token has expired")
        except jwt.InvalidTokenError as e:
            print(f"❌ JWT Token decode error: {e}")
        except Exception as e:
            print(f"❌ Error: {e}")
    
    def decode_from_file(self, file_path):
        try:
            with open(file_path, 'r') as f:
                token = f.read().strip()
            self.decode(token)
        except FileNotFoundError:
            print(f"❌ File not found: {file_path}")

if __name__ == "__main__":
    decoder = JWTDecoder()
    
    if len(sys.argv) > 1:
        if sys.argv[1] == '--file' and len(sys.argv) > 2:
            decoder.decode_from_file(sys.argv[2])
        else:
            decoder.decode(sys.argv[1])
    else:
        print("Usage:")
        print("  python decode_jwt.py <jwt_token>")
        print("  python decode_jwt.py --file <file_with_token>")
        print("")
        print("Example:")
        print("  python decode_jwt.py eyJhbGciOiJIUzI1NiJ9...")
        print("  python decode_jwt.py --file token.txt")
