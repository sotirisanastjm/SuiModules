module nexuschat::user {
    use sui::object::{UID};
    use sui::storage::{Table, TableRef};
    use sui::tx_context::TxContext;

    struct User has key {
        id: UID,
        wallet_address: address,
        username: string::String,
        email: string::String,
        password: string::String, 
        role: string::String,
        created_at: u64,
    }

    struct UserRegistry has key {
        table: Table<vector<u8>, UID>,         // Wallet-to-User mapping
        username_table: Table<vector<u8>, UID>, // Username-to-User mapping
        email_table: Table<vector<u8>, UID>,    // Email-to-User mapping
    }

    public entry fun init_registry(db_address: address, ctx: &mut TxContext) {
        move_to(&db_address, UserRegistry {
            table: table::new<vector<u8>, UID>(ctx),
            username_table: table::new<vector<u8>, UID>(ctx),
            email_table: table::new<vector<u8>, UID>(ctx),
        });
    }

    public fun get_registry(db_address: address): &UserRegistry {
        borrow_global<UserRegistry>(db_address)
    }

    public fun registry_exists(db_address: address): bool {
        exists<UserRegistry>(db_address)
    }



    public entry fun create_user(
        wallet_address: address,
        username: string::String,
        email: string::String,
        password: string::String,
        role: string::String,
        created_at: u64,
        db: &mut UserRegistry,   // Reference to the UserRegistry
        ctx: &mut TxContext
    ) {
        // Create a new User object
        let new_user = User {
            id: object::new(ctx),
            wallet_address: wallet_address,
            username: username,
            email: email,
            password: password,
            role: role,
            created_at: created_at,
        };

        let wallet_key = bcs::to_bytes(&wallet_address);
        let username_key = bcs::to_bytes(&username);
        let email_key = bcs::to_bytes(&email);

        // Store the user object inside UserRegistry
        table::add(&mut db.table, wallet_key, new_user.id);
        table::add(&mut db.username_table, username_key, new_user.id);
        table::add(&mut db.email_table, email_key, new_user.id);
    }


    

}
