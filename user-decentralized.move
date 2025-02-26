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


    public entry fun create_user(
        wallet: address,  
        username: string::String,
        email: string::String,
        password: string::String,
        role: string::String,
        created_at: u64,
        ctx: &mut TxContext
    ) {
        let user = User {
            id: object::new(ctx),  
            wallet_address: signer::address_of(wallet),
            username,
            email,
            password,
            role,
            created_at
        };

        move_to(wallet, user);
    }

    public fun user_exists(wallet_address: address): bool {
        exists<User>(wallet_address)
    }

    public fun get_user(wallet_address: address): &User {
        borrow_global<User>(wallet_address)
    }

    

}
