import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messagesContainer", "messageInput", "sendButton", "typingIndicator"]
  static values = { backendUrl: String, authUrl: String, userEmail: String }

  connect() {
    this.messages = []
    this.jwtToken = null
    this.email = this.userEmailValue
    this.isTyping = false

    this.chatSessionId = crypto.randomUUID()
    this.loadJwtToken()
    this.updateSendButton()
    this.setupAutoResize()
    this.addWelcomeMessage()
  }

  async loadJwtToken() {
    try {
      const response = await fetch(this.authUrlValue, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').getAttribute('content'),
          'Content-Type': 'application/json'
        }
      })
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }
      const data = await response.json()
      this.jwtToken = data.token
      console.log("JWT Token obtained:", this.jwtToken)
    } catch (error) {
      console.error("Error fetching JWT token:", error)
      this.addMessage("Failed to authenticate. Please refresh the page.", 'assistant')
    }
  }

  addWelcomeMessage() {
    // Add a subtle welcome message after a short delay
    setTimeout(() => {
      if (this.messages.length === 0) {
        this.addMessage("Ready to help! What would you like to know?", 'assistant')
      }
    }, 1000)
  }

  sendMessage(event) {
    event.preventDefault()

    const message = this.messageInputTarget.value.trim()
    if (!message || !this.jwtToken) return

    this.addMessage(message, 'user')
    this.messageInputTarget.value = ''
    this.updateSendButton()
    this.autoResize()

    this.sendToPythonBackend(message)
  }

  addMessage(content, role) {
    const messageId = Date.now()
    const message = {
      id: messageId,
      content: content,
      role: role,
      timestamp: new Date()
    }

    this.messages.push(message)
    this.renderMessage(message)
  }

  renderMessage(message) {
    const messageElement = document.createElement('div')
    const isUser = message.role === 'user'
    
    messageElement.className = `flex ${isUser ? 'justify-end' : 'justify-start'} mb-4 message-enter`
    
    // Add different animations for user vs assistant messages
    if (isUser) {
      messageElement.classList.add('animate-slide-in-right')
    } else {
      messageElement.classList.add('animate-slide-in-left')
    }

    const messageContent = `
      <div class="max-w-xs sm:max-w-md lg:max-w-lg px-4 py-3 rounded-2xl message-bubble ${
        isUser
          ? 'bg-gradient-to-r from-blue-600 to-purple-600 text-white rounded-br-md shadow-lg'
          : 'bg-white border border-gray-200 text-gray-900 rounded-bl-md shadow-sm hover:shadow-md transition-shadow duration-200'
      }">
        <div class="text-sm leading-relaxed whitespace-pre-wrap">${this.escapeHtml(message.content)}</div>
        <div class="text-xs mt-2 ${
          isUser ? 'text-blue-100' : 'text-gray-500'
        }">
          ${this.formatTime(message.timestamp)}
        </div>
      </div>
    `

    messageElement.innerHTML = messageContent
    this.messagesContainerTarget.appendChild(messageElement)
    this.scrollToBottom()
  }


  async sendToPythonBackend(message) {
    this.showTyping()
    
    try {
      const response = await fetch(this.backendUrlValue + '/api/v1/chat', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.jwtToken}`,
          'X-Chat-Session-Id': this.chatSessionId,
          'Origin': window.location.origin
        },
        body: JSON.stringify({ query: message })
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const data = await response.json()
      this.addMessage(data.message || 'Sorry, I could not get a response.', 'assistant')
    } catch (error) {
      console.error("Error sending message to backend:", error)
      this.addMessage("Sorry, I'm having trouble connecting to the AI. Please try again.", 'assistant')
    } finally {
      this.hideTyping()
    }
  }

  updateSendButton() {
    const hasText = this.messageInputTarget.value.trim() !== ''
    this.sendButtonTarget.disabled = !hasText || !this.jwtToken
    
    // Add visual feedback
    if (hasText && this.jwtToken) {
      this.sendButtonTarget.classList.add('animate-pulse')
    } else {
      this.sendButtonTarget.classList.remove('animate-pulse')
    }
  }

  showTyping() {
    this.isTyping = true
    this.typingIndicatorTarget.classList.remove('hidden')
    this.scrollToBottom()
  }

  hideTyping() {
    this.isTyping = false
    this.typingIndicatorTarget.classList.add('hidden')
  }

  scrollToBottom() {
    // Smooth scroll to bottom
    this.messagesContainerTarget.scrollTo({
      top: this.messagesContainerTarget.scrollHeight,
      behavior: 'smooth'
    })
  }

  formatTime(date) {
    return new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
  }

  escapeHtml(unsafe) {
    return unsafe
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }

  // Auto-resize textarea
  setupAutoResize() {
    this.messageInputTarget.addEventListener('input', () => {
      this.autoResize()
    })
  }

  autoResize() {
    const textarea = this.messageInputTarget
    textarea.style.height = 'auto'
    textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px'
  }

  // Handle Enter key (send) and Shift+Enter (new line)
  handleKeyDown(event) {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault()
      this.sendMessage(event)
    }
  }

  // Clear input
  clearInput() {
    this.messageInputTarget.value = ''
    this.updateSendButton()
    this.autoResize()
    this.messageInputTarget.focus()
  }

  // Add typing effect for long messages
  typeMessage(element, text, speed = 30) {
    let i = 0
    const timer = setInterval(() => {
      if (i < text.length) {
        element.textContent += text.charAt(i)
        i++
        this.scrollToBottom()
      } else {
        clearInterval(timer)
      }
    }, speed)
  }
}
