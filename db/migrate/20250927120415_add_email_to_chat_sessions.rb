class AddEmailToChatSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :chat_sessions, :email, :string, null: false
    add_index :chat_sessions, :email
  end
end
