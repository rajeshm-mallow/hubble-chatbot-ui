Rails.application.routes.draw do
  # JWT Authentication routes
  post '/auth', to: 'auth#create'
  get '/auth/validate', to: 'auth#validate'
  get '/auth/public_key', to: 'auth#public_key'
  
  # Simple route for the chat interface
  root "pages#home"
end
