module nexuschattest::client {
    use std::vector;
    use sui::object::{UID, new, delete};
    use sui::transfer;
    use sui::tx_context;

    struct Client has key, store {
        id: UID,
        wallet_address: address,
        role: vector<u8>,
        created_at: u64,
    }

    struct Message has key, store {
        id: UID,
        message: vector<u8>,
        date: u64,
        sender: vector<u8>,
    }

    struct Chat has key, store {
        id: UID,
        messages: vector<Message>,
    }

    struct Notepad has key, store {
        id: UID,
        folders: vector<Folder>,
    }

    struct Folder has key, store {
        id: UID,
        name: vector<u8>,
        notes: vector<Note>,
    }

    struct Note has drop, store {
        id: vector<u8>,
        message: vector<u8>,
        date: u64,
        sender: vector<u8>,
    }

    public entry fun create_user(
        signer_address: address,
        role: vector<u8>,
        created_at: u64,
        ctx: &mut tx_context::TxContext,
    ) {
        let user = Client {
            id: new(ctx),
            wallet_address: signer_address,
            role,
            created_at,
        };
        transfer::public_transfer(user, signer_address);

        let chat = Chat {
            id: new(ctx),
            messages: vector::empty<Message>(),
        };

        let notepad = Notepad {
            id: new(ctx),
            folders: vector::empty<Folder>(),
        };

        transfer::public_transfer(chat, signer_address);

        transfer::public_transfer(notepad, signer_address);
    }

    public entry fun delete_user(client: Client) {
        let Client {
            id,
            wallet_address: _,
            role: _,
            created_at: _,
        } = client;
        delete(id);
    }

    public entry fun add_message(
        chat: &mut Chat,
        message: vector<u8>,
        sender: vector<u8>,
        date: u64,
        ctx: &mut tx_context::TxContext,
    ) {
        let new_message = Message {
            id: new(ctx),
            message,
            date,
            sender,
        };

        vector::push_back(&mut chat.messages, new_message);
    }

    public entry fun create_folder(
        notepad: &mut Notepad,
        name: vector<u8>,
        ctx: &mut tx_context::TxContext,
    ) {
        let new_folder = Folder {
            id: new(ctx),
            name: name,
            notes: vector::empty<Note>(),
        };
        vector::push_back(&mut notepad.folders, new_folder);
    }

    public entry fun delete_folder(folder: Folder) {
        let Folder {
            id,
            name: _,
            notes: _,
        } = folder;
        delete(id);
    }

    // public entry fun add_note(
    //     folder: &mut Folder,
    //     id: vector<u8>,
    //     message: vector<u8>,
    //     date: u64,
    //     sender: vector<u8>
    // ){
    //     let new_note = Note {
    //         id: id,
    //         message: message,
    //         date: date,
    //         sender: sender
    //     };
    //     vector::push_back(&mut folder.notes, new_note);
    // }

    public entry fun add_note(
        notepad: &mut Notepad,
        folder_index: u64, // index of folder in notepad.folders
        id: vector<u8>,
        message: vector<u8>,
        date: u64,
        sender: vector<u8>,
    ) {
        let new_note = Note {
            id,
            message,
            date,
            sender,
        };

        let folder = vector::borrow_mut(&mut notepad.folders, folder_index);
        vector::push_back(&mut folder.notes, new_note);
    }
}
