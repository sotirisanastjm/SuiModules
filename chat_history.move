module nexuschat::chat_history {
    use sui::object::UID;
    use sui::tx_context::TxContext;

    struct MessageItem has store {
        id: vector<u8>, 
        date: vector<u8>, 
        message: vector<u8>, 
        sender: u8, 
    }

    struct ChatHistory has key, store {
        id: UID, 
        user_id: vector<u8>, 
        messages: vector<MessageItem>, 
        is_deleted: bool, 
    }

    
    struct ChatHistoryRegistry has key {
        id: UID, 
        chat_histories: vector<ChatHistory>, 
    }

    
    public fun create_registry(ctx: &mut TxContext): ChatHistoryRegistry {
        ChatHistoryRegistry {
            id: UID::new(ctx),
            chat_histories: vector[]
        }
    }

    /// Create or reuse a ChatHistory for a User
    public fun create_chat_history(
        registry: &mut ChatHistoryRegistry,
        user_id: vector<u8>,
        ctx: &mut TxContext
    ): ChatHistory {
        // Search for an existing deleted chat history
        for chat_history in &mut registry.chat_histories {
            if chat_history.is_deleted {
                // Override the deleted chat history
                chat_history.user_id = user_id;
                chat_history.messages = vector[]; // Reset messages
                chat_history.is_deleted = false; // Reactivate
                return *chat_history;
            }
        }

        // If no deleted chat history is found, create a new one
        let new_chat_history = ChatHistory {
            id: UID::new(ctx),
            user_id,
            messages: vector[], // Start with no messages
            is_deleted: false,
        };

        // Add the new chat history to the registry
        vector::push_back(&mut registry.chat_histories, new_chat_history);

        // Return the new chat history
        *vector::last_mut(&mut registry.chat_histories)
    }


    /// Push new messages to a users ChatHistory
    public fun push_messages(
        registry: &mut ChatHistoryRegistry,
        user_id: vector<u8>,
        new_messages: vector<MessageItem>
    ) {
        for chat_history in &mut registry.chat_histories {
            if chat_history.user_id == user_id && !chat_history.is_deleted {
                vector::extend(&mut chat_history.messages, new_messages);
                return;
            }
        }
        // If not found, do nothing (could also throw an error)
    }

    /// Fetch ChatHistory for a User
    public fun get_chat_history(
        registry: &ChatHistoryRegistry,
        user_id: vector<u8>
    ): vector<MessageItem> {
        for chat_history in &registry.chat_histories {
            if chat_history.user_id == user_id && !chat_history.is_deleted {
                return chat_history.messages;
            }
        }
        vector[] // Return empty if not found
    }

    /// Delete a User's ChatHistory (mark for reuse)
    public fun delete_chat_history(
        registry: &mut ChatHistoryRegistry,
        user_id: vector<u8>
    ) {
        for chat_history in &mut registry.chat_histories {
            if chat_history.user_id == user_id {
                chat_history.is_deleted = true; // Mark as deleted
                chat_history.messages = vector[]; // Clear messages
                return;
            }
        }
        // If not found, do nothing
    }

    /// Update a User's ChatHistory by emptying it and storing it as empty
    public fun update_chat_history(
        registry: &mut ChatHistoryRegistry,
        user_id: vector<u8>
    ) {
        for chat_history in &mut registry.chat_histories {
            if chat_history.user_id == user_id && !chat_history.is_deleted {
                // Empty the current messages and store the empty chat history
                chat_history.messages = vector[];
                return;
            }
        }
        // If not found, do nothing
    }
}
