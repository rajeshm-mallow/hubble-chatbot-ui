// CLIENT CODE - No Decoding Required!

class ChatController {
  async connect() {
    // 1. Get encoded email from Rails backend
    const response = await fetch('/auth', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    })
    
    const data = await response.json()
    // data = { 
    //   "encoded_email": "YWRtaW5AaHViYmxlLWNoYXRib3QuY29t",
    //   "email": "admin@hubble-chatbot.com" 
    // }
    
    // 2. Store the encoded email (DON'T DECODE IT!)
    this.encodedEmail = data.encoded_email  // "YWRtaW5AaHViYmxlLWNoYXRib3QuY29t"
    this.userEmail = data.email             // "admin@hubble-chatbot.com" (for display only)
    
    console.log('Encoded email stored:', this.encodedEmail)
    console.log('User email (for display):', this.userEmail)
  }
  
  async sendMessage(message) {
    // 3. Send message to Python backend with encoded email in header
    const response = await fetch('http://localhost:8000/chat', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-User-Email': this.encodedEmail  // Send encoded email as-is (NO DECODING!)
      },
      body: JSON.stringify({
        message: message,
        email: this.userEmail,  // Also send plain email for convenience
        conversation_history: this.messages
      })
    })

    const data = await response.json()
    return data.response
  }
}

// The client NEVER does this:
// const decoded = atob(this.encodedEmail)  // ❌ DON'T DO THIS!
// The client just passes the encoded string along!
