# Hubble Chatbot API Documentation

## JWT Authentication

This API uses JWT (JSON Web Tokens) for authentication. All protected endpoints require a valid JWT token in the Authorization header.

### Authentication Flow

1. **Get JWT Token**: Send a POST request to `/auth` with an email
2. **Use Token**: Include the token in the Authorization header for all subsequent requests

## API Endpoints

### Authentication

#### POST /auth
Generate a JWT token for the given email.

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "email": "user@example.com",
  "expires_at": "2024-01-02T12:00:00Z"
}
```

#### GET /auth/validate
Validate a JWT token.

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

**Response:**
```json
{
  "valid": true,
  "email": "user@example.com"
}
```

### Chat Sessions

#### GET /chat_sessions
Get all chat sessions for the authenticated user.

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

**Response:**
```json
[
  {
    "id": 1,
    "email": "user@example.com",
    "title": "New chat",
    "created_at": "2024-01-01T12:00:00Z",
    "updated_at": "2024-01-01T12:00:00Z"
  }
]
```

#### POST /chat_sessions
Create a new chat session.

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

**Request:**
```json
{
  "title": "My New Chat"
}
```

**Response:**
```json
{
  "id": 1,
  "email": "user@example.com",
  "title": "My New Chat",
  "created_at": "2024-01-01T12:00:00Z",
  "updated_at": "2024-01-01T12:00:00Z"
}
```

#### GET /chat_sessions/:id
Get a specific chat session with its messages.

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

**Response:**
```json
{
  "chat_session": {
    "id": 1,
    "email": "user@example.com",
    "title": "My Chat",
    "created_at": "2024-01-01T12:00:00Z",
    "updated_at": "2024-01-01T12:00:00Z"
  },
  "messages": [
    {
      "id": 1,
      "content": "Hello!",
      "role": "user",
      "created_at": "2024-01-01T12:00:00Z"
    }
  ]
}
```

#### DELETE /chat_sessions/:id
Delete a chat session.

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

**Response:**
```json
{
  "message": "Chat session deleted successfully"
}
```

### Messages

#### GET /chat_sessions/:chat_session_id/messages
Get all messages for a chat session.

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

**Response:**
```json
[
  {
    "id": 1,
    "content": "Hello!",
    "role": "user",
    "created_at": "2024-01-01T12:00:00Z"
  },
  {
    "id": 2,
    "content": "Hi there! How can I help you?",
    "role": "assistant",
    "created_at": "2024-01-01T12:01:00Z"
  }
]
```

#### POST /chat_sessions/:chat_session_id/messages
Send a message to a chat session.

**Headers:**
```
Authorization: Bearer <your-jwt-token>
```

**Request:**
```json
{
  "message": {
    "content": "Hello, how are you?"
  }
}
```

**Response:**
```json
{
  "user_message": {
    "id": 1,
    "content": "Hello, how are you?",
    "role": "user",
    "created_at": "2024-01-01T12:00:00Z"
  },
  "assistant_message": {
    "id": 2,
    "content": "I'm doing well, thank you! How can I assist you today?",
    "role": "assistant",
    "created_at": "2024-01-01T12:00:01Z"
  }
}
```

## Environment Variables

Make sure to set these environment variables in your `.env` file:

```env
# JWT Configuration
JWT_SECRET_KEY=your-super-secret-jwt-key-here-make-it-long-and-random
JWT_EXPIRATION_TIME=24h

# LLM Backend (optional)
LLM_BACKEND_URL=https://your-llm-backend.com/generate
```

## Error Responses

All endpoints return appropriate HTTP status codes and error messages:

- `400 Bad Request`: Invalid request data
- `401 Unauthorized`: Missing or invalid JWT token
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error

Example error response:
```json
{
  "error": "Unauthorized. Valid JWT token required."
}
```
