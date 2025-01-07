module nexuschat::user {
    use sui::object::{UID, ID};
    use sui::storage::{Table, TableRef};
    use sui::tx_context::TxContext;

    struct User has key {
        id: UID,
        wallet_address: vector<u8>,
        username: vector<u8>,
        email: vector<u8>,
        password: vector<u8>,
        role: vector<u8>,
        created_at: u64,
        is_deleted: bool,
    }

    struct UserRegistry has key {
        table: Table<vector<u8>, ID>, 
        username_table: Table<vector<u8>, ID>, 
        email_table: Table<vector<u8>, ID>, 
    }

    struct UserRegistry has key {
        table: Table<vector<u8>, ID>, 
        username_table: Table<vector<u8>, ID>, 
        email_table: Table<vector<u8>, ID>, 
    }

    public fun create_user(
        registry: &mut UserRegistry,
        id: UID,
        wallet_address: vector<u8>,
        username: vector<u8>,
        email: vector<u8>,
        password: vector<u8>,
        role: vector<u8>,
        created_at: u64,
        ctx: &mut TxContext
    ): User {
        let user_id_opt = Table::borrow(&registry.table, &wallet_address);
        if let Some(user_id) = user_id_opt {
            if exists<User>(*user_id) {
                let mut user = borrow_global_mut<User>(*user_id);
                if (user.is_deleted) {
                    // Reuse the deleted user
                    user.id = id;
                    user.username = username;
                    user.password = password;
                    user.email = email;
                    user.role = role;
                    user.created_at = created_at;
                    user.is_deleted = false;
                    return user;
                }
            }
        }

        let user = User {
            id: UID::new(ctx),
            wallet_address: wallet_address.clone(),
            username: username.clone(),
            email,
            password,
            role,
            created_at,
            is_deleted: false,
        };

        let user_id = ID::from(&user.id);
        Table::add(&mut registry.table, wallet_address, user_id);
        Table::add(&mut registry.username_table, username, user_id);  
        Table::add(&mut registry.email_table, email, user_id); 
        user
    }

    public fun get_user_by_wallet(
        registry: &UserRegistry,
        wallet_address: vector<u8>
    ): Option<User> {
        let user_id_opt = Table::borrow(&registry.table, &wallet_address);
        match user_id_opt {
            Some(user_id) => {
                if exists<User>(*user_id) {
                    let user = borrow_global<User>(*user_id);
                    Some(user)
                } else {
                    None
                }
            },
            None => None,
        }
    }
}