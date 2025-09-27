#!/usr/bin/env python3
"""
Example Python backend for Hubble Chatbot
This shows how the frontend should communicate with your Python backend
Uses RSA public key for JWT verification
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import jwt
import json
import os
import requests
from datetime import datetime

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Configuration
RAILS_BACKEND_URL = os.getenv('RAILS_BACKEND_URL', 'http://localhost:3000')
PUBLIC_KEY_PATH = os.getenv('JWT_PUBLIC_KEY_PATH', 'keys/public_key.pem')

def get_public_key():
    """Get public key from Rails backend or local file"""
    try:
        # Try to get public key from Rails backend first
        response = requests.get(f'{RAILS_BACKEND_URL}/auth/public_key', timeout=5)
        if response.status_code == 200:
            return response.text
    except Exception as e:
        print(f"Could not fetch public key from Rails backend: {e}")
    
    # Fallback to local file
    try:
        with open(PUBLIC_KEY_PATH, 'r') as f:
            return f.read()
    except FileNotFoundError:
        print(f"Public key file not found: {PUBLIC_KEY_PATH}")
        return None

def verify_jwt_token(token):
    """Verify JWT token using RSA public key"""
    public_key = get_public_key()
    if not public_key:
        print("No public key available for JWT verification")
        return None
    
    try:
        # Decode the JWT token using RSA public key
        payload = jwt.decode(token, public_key, algorithms=['RS256'])
        return payload.get('email')
    except jwt.ExpiredSignatureError:
        print("JWT token expired")
        return None
    except jwt.InvalidTokenError as e:
        print(f"Invalid JWT token: {e}")
        return None
    except Exception as e:
        print(f"Error verifying JWT token: {e}")
        return None

@app.route('/chat', methods=['POST'])
def chat():
    """Handle chat messages from the frontend"""
    try:
        # Get the Authorization header
        auth_header = request.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            return jsonify({'error': 'Missing or invalid authorization header'}), 401
        
        # Extract token
        token = auth_header.split(' ')[1]
        
        # Verify token and get email
        email = verify_jwt_token(token)
        if not email:
            return jsonify({'error': 'Invalid or expired token'}), 401
        
        # Get request data
        data = request.get_json()
        message = data.get('message', '')
        conversation_history = data.get('conversation_history', [])
        
        if not message:
            return jsonify({'error': 'Message is required'}), 400
        
        # Here you would integrate with your AI model
        # For this example, we'll just echo back a response with the email
        response_text = f"Hello {email}! I received your message: '{message}'. I have {len(conversation_history)} previous messages in context. How can I help you today?"
        
        # Log the interaction
        print(f"Chat from {email}: {message}")
        print(f"Response: {response_text}")
        
        return jsonify({
            'response': response_text,
            'email': email,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        print(f"Error in chat endpoint: {str(e)}")
        return jsonify({'error': 'Internal server error'}), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({'status': 'healthy', 'timestamp': datetime.now().isoformat()})

@app.route('/public_key', methods=['GET'])
def public_key():
    """Endpoint to get public key (for debugging)"""
    public_key = get_public_key()
    if public_key:
        return public_key, 200, {'Content-Type': 'text/plain'}
    else:
        return jsonify({'error': 'Public key not available'}), 500

if __name__ == '__main__':
    print("Starting Hubble Chatbot Python Backend...")
    print("Make sure to install required packages:")
    print("pip install flask flask-cors pyjwt requests")
    print(f"\nRails Backend URL: {RAILS_BACKEND_URL}")
    print(f"Public Key Path: {PUBLIC_KEY_PATH}")
    print("Backend will be available at: http://localhost:8000")
    print("Uses RSA public key for JWT verification")
    app.run(host='0.0.0.0', port=8000, debug=True)
