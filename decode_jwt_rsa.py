#!/usr/bin/env python3
"""
RSA JWT Decoder for Testing
Decodes JWT tokens using RSA public key for testing and debugging
"""

import jwt
import json
import sys
import os
from datetime import datetime

class RSAJWTDecoder:
    def __init__(self, public_key_path=None):
        self.public_key_path = public_key_path or 'keys/public_key.pem'
    
    def decode(self, token):
        try:
            # Decode without verification first to see the payload
            decoded_payload = jwt.decode(token, options={"verify_signature": False})
            print("🔓 JWT Token Decoded (without verification):")
            print("=" * 50)
            print(json.dumps(decoded_payload, indent=2))
            print("=" * 50)
            
            # Now decode with RSA public key verification
            with open(self.public_key_path, 'r') as f:
                public_key = f.read()
            
            verified_payload = jwt.decode(token, public_key, algorithms=['RS256'])
            print("✅ JWT Token Verified with RSA Public Key:")
            print("=" * 50)
            print(json.dumps(verified_payload, indent=2))
            print("=" * 50)
            
            # Show token info
            print("📊 Token Information:")
            print(f"- Email: {verified_payload['email']}")
            print(f"- Issued At: {datetime.fromtimestamp(verified_payload['iat'])}")
            print(f"- Expires At: {datetime.fromtimestamp(verified_payload['exp'])}")
            print(f"- Issuer: {verified_payload['iss']}")
            print(f"- Algorithm: RS256 (RSA)")
            print(f"- Valid: {'Yes' if datetime.fromtimestamp(verified_payload['exp']) > datetime.now() else 'No'}")
            
        except jwt.ExpiredSignatureError:
            print("❌ JWT Token has expired")
        except jwt.InvalidTokenError as e:
            print(f"❌ JWT Token decode error: {e}")
        except FileNotFoundError:
            print(f"❌ Public key file not found: {self.public_key_path}")
        except Exception as e:
            print(f"❌ Error: {e}")
    
    def decode_from_file(self, file_path):
        try:
            with open(file_path, 'r') as f:
                token = f.read().strip()
            self.decode(token)
        except FileNotFoundError:
            print(f"❌ File not found: {file_path}")
    
    def show_key_info(self):
        print("🔑 RSA Key Information:")
        print("=" * 50)
        
        if os.path.exists(self.public_key_path):
            with open(self.public_key_path, 'r') as f:
                public_key = f.read()
            print(f"Public Key:")
            print(f"- Path: {self.public_key_path}")
            print(f"- Size: {len(public_key)} characters")
        else:
            print(f"❌ Public key not found: {self.public_key_path}")

if __name__ == "__main__":
    decoder = RSAJWTDecoder()
    
    if len(sys.argv) > 1:
        if sys.argv[1] == '--file' and len(sys.argv) > 2:
            decoder.decode_from_file(sys.argv[2])
        elif sys.argv[1] == '--keys':
            decoder.show_key_info()
        else:
            decoder.decode(sys.argv[1])
    else:
        print("Usage:")
        print("  python decode_jwt_rsa.py <jwt_token>")
        print("  python decode_jwt_rsa.py --file <file_with_token>")
        print("  python decode_jwt_rsa.py --keys")
        print("")
        print("Example:")
        print("  python decode_jwt_rsa.py eyJhbGciOiJSUzI1NiJ9...")
        print("  python decode_jwt_rsa.py --file rsa_jwt_token.txt")
        print("  python decode_jwt_rsa.py --keys")
