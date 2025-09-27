# Hubble Chatbot Frontend - JWT Authentication

A clean, professional chat interface built with Rails, Stimulus, and Tailwind CSS that communicates with a Python backend using **JWT authentication with email from environment**.

## 🔐 JWT Authentication Features

- **Environment-based Email**: Email configured in .env file
- **JWT Token Generation**: Server-side JWT token creation
- **Authorization Headers**: JWT tokens sent in Authorization header
- **Secure Validation**: Proper JWT validation on both backends
- **Professional UI**: Clean, modern design with Tailwind CSS

## Features

- **Professional UI**: Clean, modern design with Tailwind CSS
- **JWT Authentication**: Secure token-based authentication
- **Real-time Chat**: Smooth message sending and receiving
- **Typing Indicators**: Visual feedback during AI responses
- **Responsive Design**: Works on desktop and mobile
- **Error Handling**: Graceful error messages and retry logic
- **Environment Configuration**: Email configured in .env file

## Setup

### 1. Environment Variables

Create a `.env` file in the root directory:

```env
# JWT Configuration
JWT_SECRET_KEY=your-super-secret-jwt-key-here-make-it-long-and-random

# User Email (configured in environment)
USER_EMAIL=admin@hubble-chatbot.com

# Python Backend URL
PYTHON_BACKEND_URL=http://localhost:8000

# Application Configuration
RAILS_ENV=development
```

### 2. Install Dependencies

```bash
# Rails dependencies
bundle install

# Python dependencies
pip install -r requirements.txt
```

### 3. Start the Servers

```bash
# Start Rails server
rails server

# Start Python backend (in another terminal)
python python_backend_example.py
```

The frontend will be available at `http://localhost:3000`

## How It Works

### JWT Authentication Flow

1. **Page Load**: Frontend requests JWT token from Rails backend
2. **Server-side Generation**: Rails backend generates JWT token with configured email
3. **Token Response**: Frontend receives JWT token
4. **API Requests**: Frontend sends JWT token in Authorization header
5. **Token Validation**: Python backend validates JWT token and extracts email

### Chat Flow

1. **Message Input**: User types a message and presses Enter or clicks send
2. **JWT Headers**: Request includes JWT token in Authorization header
3. **Python Backend**: Backend validates JWT and processes the message
4. **Response Display**: AI response is displayed in the chat interface

### JWT Token Structure

```json
{
  "email": "admin@hubble-chatbot.com",
  "exp": 1234567890,
  "iat": 1234567890,
  "iss": "hubble-chatbot"
}
```

## API Communication

### Rails Backend Authentication

```javascript
POST /auth
Headers:
  Content-Type: application/json

Response:
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "admin@hubble-chatbot.com",
  "expires_at": "2024-01-02T12:00:00Z"
}
```

### Python Backend Communication

```javascript
POST /chat
Headers:
  Content-Type: application/json
  Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

Body:
{
  "message": "Hello, how are you?",
  "email": "admin@hubble-chatbot.com",
  "conversation_history": [...]
}
```

### Expected Response

```javascript
{
  "response": "Hello! I'm doing well, thank you for asking.",
  "email": "admin@hubble-chatbot.com",
  "timestamp": "2024-01-01T12:00:01.000Z"
}
```

## Security Architecture

### Frontend (Rails + Stimulus)
- ✅ **No JWT Secrets**: Secret never exposed to client-side code
- ✅ **Token Request**: Requests JWT token from secure backend endpoint
- ✅ **Authorization Header**: Uses Bearer token in Authorization header
- ✅ **Clean Code**: Simple, readable JavaScript

### Backend (Rails)
- ✅ **Server-side Generation**: JWT tokens generated server-side
- ✅ **Secret Protection**: JWT secret kept in environment variables
- ✅ **Email from Environment**: Email configured in .env file
- ✅ **Token Validation**: Validates tokens before processing requests

### Python Backend
- ✅ **JWT Validation**: Validates JWT tokens using shared secret
- ✅ **Email Extraction**: Extracts email from validated token
- ✅ **Secure Processing**: Processes requests only with valid tokens

## Configuration

### Changing the Email

To change the user email, update the `USER_EMAIL` variable in your `.env` file:

```env
USER_EMAIL=your-new-email@example.com
```

Then restart the Rails server.

### Backend URL

Change the Python backend URL by setting the `PYTHON_BACKEND_URL` environment variable:

```env
PYTHON_BACKEND_URL=http://your-backend-server.com
```

### JWT Secret

The JWT secret must be the same in both Rails and Python backends:

```env
# Rails .env
JWT_SECRET_KEY=your-super-secret-jwt-key-here-make-it-long-and-random

# Python environment
export JWT_SECRET_KEY=your-super-secret-jwt-key-here-make-it-long-and-random
```

## File Structure

```
app/
├── controllers/
│   └── auth_controller.rb         # JWT token generation
├── javascript/
│   └── controllers/
│       └── chat_controller.js    # Chat functionality with JWT
├── views/
│   └── pages/
│       └── home.html.erb         # Chat interface
└── assets/
    └── stylesheets/
        └── application.css       # Custom styles
```

## Testing

Run the JWT authentication test:

```bash
ruby test_jwt_auth.rb
```

This will verify:
- JWT token generation works correctly
- Token validation functions properly
- Authorization header authentication works

## Benefits of JWT Approach

### 🔐 **Security**
- **Server-side Generation**: JWT tokens created on Rails backend
- **No Secret Exposure**: JWT secret never sent to frontend
- **Token Validation**: Proper JWT validation on Python backend
- **Email from Environment**: Secure email configuration

### 🚀 **Simplicity**
- **Environment Configuration**: Email set in .env file
- **Automatic Authentication**: No user input required
- **Clean Headers**: Standard Authorization header format
- **Easy Integration**: Works with any Python backend

### 🛠️ **Maintenance**
- **Standard JWT**: Uses industry-standard JWT tokens
- **Easy Debugging**: Clear token structure and validation
- **Scalable**: Can easily add more claims to JWT payload
- **Production Ready**: Secure and robust authentication

## Quick Start

1. **Configure Environment**: Set `USER_EMAIL` and `JWT_SECRET_KEY` in `.env`
2. **Start Rails Server**: `rails server`
3. **Start Python Backend**: `python python_backend_example.py`
4. **Open Browser**: Visit `http://localhost:3000`
5. **Start Chatting**: Type a message and press Enter!

The system will automatically authenticate using the configured email and be ready to communicate securely with your Python backend using JWT tokens in the Authorization header.

## Production Deployment

For production deployment:

1. **Use HTTPS**: Ensure all communication is over HTTPS
2. **Secure Environment**: Use secure environment variable management
3. **Strong Secrets**: Use cryptographically strong JWT secrets
4. **CORS Policy**: Configure proper CORS policies
5. **Rate Limiting**: Implement rate limiting on authentication endpoints
6. **Monitoring**: Monitor authentication failures and suspicious activity

The system is now **production-ready** with proper JWT authentication! 🚀
