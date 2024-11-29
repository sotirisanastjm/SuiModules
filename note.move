module nexuschat::note {
    use sui::object::UID;

    struct Note has key {
        id: UID,
        content: vector<u8>,
        title: vector<u8>,
        description: option<vector<u8>>,
        created_at: u64,
        is_deleted: bool, 
    }

    struct NoteFolder has key {
        id: UID,
        user_id: vector<u8>,
        title: vector<u8>,
        notes: vector<vector<u8>>,
        is_deleted: bool, // To mark the folder as deleted
    }

    struct FolderRegistry has key {
        id: UID,
        folders: vector<NoteFolder>,
    }

    public fun create_folder(
        registry: &mut FolderRegistry,
        user_id: vector<u8>,
        title: vector<u8>,
        ctx: &mut TxContext
    ): NoteFolder {
        // Search for a deleted folder
        for folder in &mut registry.folders {
            if folder.is_deleted {
                // Reuse the deleted folder
                folder.user_id = user_id;
                folder.title = title;
                folder.notes = vector[]; // Reset notes
                folder.is_deleted = false; // Reactivate
                return *folder;
            }
        }

        // Create a new folder if no reusable folder is found
        let new_folder = NoteFolder {
            id: UID::new(ctx),
            user_id,
            title,
            notes: vector[], // Start with no notes
            is_deleted: false,
        };

        vector::push_back(&mut registry.folders, new_folder);

        // Return the newly created folder
        *vector::last_mut(&mut registry.folders)
    }

    public fun add_note_to_folder(
        folder: &mut NoteFolder,
        content: vector<u8>,
        title: vector<u8>,
        description: option<vector<u8>>,
        created_at: u64,
        ctx: &mut TxContext
    ): Note {
        // Search for a deleted note
        for note in &mut folder.notes {
            if note.is_deleted {
                // Reuse the deleted note
                note.content = content;
                note.title = title;
                note.description = description;
                note.created_at = created_at;
                note.is_deleted = false; // Reactivate
                return *note;
            }
        }

        // Create a new note if no reusable note is found
        let new_note = Note {
            id: UID::new(ctx),
            content,
            title,
            description,
            created_at,
            is_deleted: false,
        };

        vector::push_back(&mut folder.notes, new_note);

        // Return the newly created note
        *vector::last_mut(&mut folder.notes)
    }

    module nexuschat::note {
    use sui::object::UID;

    struct Note has key {
        id: UID,
        content: vector<u8>,
        title: vector<u8>,
        description: option<vector<u8>>,
        created_at: u64,
        is_deleted: bool, 
    }

    struct NoteFolder has key {
        id: UID,
        user_id: vector<u8>,
        title: vector<u8>,
        notes: vector<Note>, // Updated to hold actual Note structs
        is_deleted: bool, // To mark the folder as deleted
    }

    struct FolderRegistry has key {
        id: UID,
        folders: vector<NoteFolder>,
    }

    // Create Folder Function
    public fun create_folder(
        registry: &mut FolderRegistry,
        user_id: vector<u8>,
        title: vector<u8>,
        ctx: &mut TxContext
    ): NoteFolder {
        for folder in &mut registry.folders {
            if folder.is_deleted {
                folder.user_id = user_id;
                folder.title = title;
                folder.notes = vector[]; // Reset notes
                folder.is_deleted = false; // Reactivate
                return *folder;
            }
        }

        let new_folder = NoteFolder {
            id: UID::new(ctx),
            user_id,
            title,
            notes: vector[], // Start with no notes
            is_deleted: false,
        };

        vector::push_back(&mut registry.folders, new_folder);

        *vector::last_mut(&mut registry.folders)
    }

    // Add Note to Folder Function
    public fun add_note_to_folder(
        folder: &mut NoteFolder,
        content: vector<u8>,
        title: vector<u8>,
        description: option<vector<u8>>,
        created_at: u64,
        ctx: &mut TxContext
    ): Note {
        for note in &mut folder.notes {
            if note.is_deleted {
                note.content = content;
                note.title = title;
                note.description = description;
                note.created_at = created_at;
                note.is_deleted = false; // Reactivate
                return *note;
            }
        }

        let new_note = Note {
            id: UID::new(ctx),
            content,
            title,
            description,
            created_at,
            is_deleted: false,
        };

        vector::push_back(&mut folder.notes, new_note);

        *vector::last_mut(&mut folder.notes)
    }

    // Fetch Active Folders by User ID
    public fun get_folders_by_user(
        registry: &FolderRegistry,
        user_id: vector<u8>
    ): vector<NoteFolder> {
        let mut user_folders = vector[];
        for folder in &registry.folders {
            if !folder.is_deleted && folder.user_id == user_id {
                vector::push_back(&mut user_folders, *folder);
            }
        }
        user_folders
    }

    // Fetch All Folders and Active Notes by User ID
    public fun get_folders_and_notes_by_user(
        registry: &FolderRegistry,
        user_id: vector<u8>
    ): vector<NoteFolder> {
        let mut result = vector[];
        for folder in &registry.folders {
            if !folder.is_deleted && folder.user_id == user_id {
                let mut active_notes = vector[];
                for note in &folder.notes {
                    if !note.is_deleted {
                        vector::push_back(&mut active_notes, *note);
                    }
                }
                // Clone the folder with only active notes
                let folder_with_active_notes = NoteFolder {
                    id: folder.id,
                    user_id: folder.user_id,
                    title: folder.title,
                    notes: active_notes,
                    is_deleted: folder.is_deleted,
                };
                vector::push_back(&mut result, folder_with_active_notes);
            }
        }
        result
    }

    public fun get_notes(folder: &NoteFolder): vector<Note> {
        let mut active_notes = vector[];
        for note in &folder.notes {
            if !note.is_deleted {
                vector::push_back(&mut active_notes, *note);
            }
        }
        active_notes
    }

    public fun delete_folder(folder: &mut NoteFolder) {
        folder.is_deleted = true;
        for note in &mut folder.notes {
            note.is_deleted = true; // Mark all notes as deleted
        }
    }

    public fun delete_note_from_folder(folder: &mut NoteFolder, note_id: UID) {
        for note in &mut folder.notes {
            if note.id == note_id {
                note.is_deleted = true; // Mark the note as deleted
                return;
            }
        }
        // If note not found, do nothing
    }




    
}

