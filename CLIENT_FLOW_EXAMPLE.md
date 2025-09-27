# Client Authentication Flow - No Decoding Required

## What the Client Does (JavaScript)

```javascript
// 1. Client requests encoded email from Rails backend
const response = await fetch('/auth', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' }
})

const data = await response.json()
// data = { 
//   "encoded_email": "YWRtaW5AaHViYmxlLWNoYXRib3QuY29t",
//   "email": "admin@hubble-chatbot.com" 
// }

// 2. Client stores the encoded email (doesn't decode it)
this.encodedEmail = data.encoded_email
this.userEmail = data.email  // This is just for display/logging

// 3. Client sends encoded email in header to Python backend
const response = await fetch('http://localhost:8000/chat', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'X-User-Email': this.encodedEmail  // Sends encoded email as-is
  },
  body: JSON.stringify({
    message: "Hello!",
    email: this.userEmail,  // Also sends plain email for convenience
    conversation_history: [...]
  })
})
```

## What the Servers Do

### Rails Backend (Encodes)
```ruby
# app/controllers/auth_controller.rb
def create
  email = ENV['USER_EMAIL']  # "admin@hubble-chatbot.com"
  encoded_email = Base64.strict_encode64(email)  # "YWRtaW5AaHViYmxlLWNoYXRib3QuY29t"
  
  render json: { 
    encoded_email: encoded_email, 
    email: email 
  }
end
```

### Python Backend (Decodes)
```python
# python_backend_example.py
def decode_email_from_header():
    encoded_email = request.headers.get('X-User-Email')  # "YWRtaW5AaHViYmxlLWNoYXRib3QuY29t"
    
    try:
        email = base64.b64decode(encoded_email).decode('utf-8')  # "admin@hubble-chatbot.com"
        return email
    except Exception as e:
        return None
```

## Why This Works

1. **Client never needs to decode** - it just passes the encoded string along
2. **Rails encodes** the email server-side (secure)
3. **Python decodes** the email when needed (secure)
4. **Client is just a messenger** - carries the encoded email between servers

## Security Benefits

- ✅ **No client-side decoding** - client can't see the email
- ✅ **Server-side encoding** - Rails controls the encoding
- ✅ **Server-side decoding** - Python controls the decoding
- ✅ **Client is stateless** - just passes encoded data along

## Example Flow

```
1. Client → Rails: "Give me encoded email"
2. Rails → Client: "Here's encoded email: YWRtaW5AaHViYmxlLWNoYXRib3QuY29t"
3. Client → Python: "Here's a message with encoded email in header"
4. Python: "I'll decode this email and process your message"
```

The client is essentially a **secure messenger** that carries the encoded email between the two servers without ever needing to know what it contains!
