use anyhow::anyhow;
use anyhow::Result;
use log::error;
use std::io::Write;
use std::path::PathBuf;
use walkdir::WalkDir;

use crate::config::get_config;
use crate::constants::STORE_DIR;

/// Returns a list of files in the given directory with the `.desktop` extension.
///
/// # Arguments
/// * `dir` - A path to the directory to search.
///
/// # Returns
/// A `Vec<PathBuf>` containing paths to files with the `.desktop` extension.
/// If no such files are found, the vector will be empty.
///
/// # Panics
/// This function will panic if the directory cannot be accessed.
fn find_desktop_files(dir: &str) -> Vec<PathBuf> {
    let mut desktop_files = Vec::new();

    for entry in WalkDir::new(dir).into_iter().filter_map(Result::ok) {
        if entry.file_type().is_file() {
            if let Some(extension) = entry.path().extension() {
                if extension == "desktop" {
                    desktop_files.push(entry.path().to_path_buf());
                }
            }
        }
    }

    desktop_files
}

/*
This module should create symlinks in `$HOME/.local/share/flatpak/overrides`
(or $XDG_STATE_DIR or something liek that) that target files at
`/var/lib/idwt/store/`. These files at `/var/lib/idwt/store/` will have
configuration that disables the flatpak's access to the x11 and wayland socket,
and blocks internet.

After this module creates all the files it should then delete all the files
in `$HOME/.local/share/flatpak/overrides` that are targetting a non-existent file pointing to the store somewhere.
This is often called a broken symlink.
*/

fn get_flatpak_desktops() -> Result<Vec<PathBuf>> {
    let system_dir = "/var/lib/flatpak/exports/bin";
    let system_files = find_desktop_files(system_dir);

    let config = get_config()?;

    let mut user_files: Vec<PathBuf> = vec![];

    for user in config.affected_users {
        let this_dir = format!("/home/{user}/.local/share/flatpak/exports/bin");
        let this_files = find_desktop_files(&this_dir);
        for file in this_files {
            user_files.push(file);
        }
    }

    let all_files = [system_files, user_files].concat();
    Ok(all_files)
}

pub fn apply_block_flatpaks() -> Result<()> {
    let result = karen::escalate_if_needed();
    if let Err(error) = result {
        error!("Error escalating privileges");
        return Err(anyhow!(error.to_string()));
    }

    let config = get_config()?;

    // use .file_stem() to get the raw file name (which is the flatpak id)
    let desktop_files = get_flatpak_desktops();

    /*
    loop through all desktop_files
        get file_stem (app_id)
        if app_id in blocked -> block
        if block-by-default and app_id not in allowed -> block
        allow
    */
    for app in desktop_files.unwrap_or_default() {
        let app_id = app
            .file_stem()
            .unwrap_or_default()
            .to_str()
            .unwrap_or_default()
            .to_owned();
        if config.block_flatpaks.block.contains(&app_id)
            || (config.block_flatpaks.block_by_default
                && !(config.block_flatpaks.allow.contains(&app_id)))
        {
            let store_file_path = format!("{STORE_DIR}/flatpak_overrides/{app_id}");
            let file = std::fs::OpenOptions::new()
                .write(true)
                .create(true) // Create the file if it doesn't exist.
                .truncate(true) // Truncate (overwrite) the file if it exists.
                .open(&store_file_path);

            let mut file = match file {
                Ok(file_obj) => file_obj,
                Err(err) => {
                    log::error!(
                        "Error opening store file `{store_file_path}` override for writing: {err}"
                    );
                    continue;
                }
            };

            let mut override_content = String::new();

            override_content.push_str("[Context]\n");
            override_content.push_str("shared=!ipc;!network\n");
            override_content.push_str("sockets=!pulseaudio;!wayland;!x11");

            if let Err(err) = file.write_all(&override_content.into_bytes()) {
                log::error!(
                    "Error writing contents to store's override file for `{app_id}`: {err}"
                );
            }
            for username in &config.affected_users {
                let home_dir = if let Ok(Some(user)) = nix::unistd::User::from_name(username) {
                    // Return the home directory if available
                    user.dir.to_str().map(|s| s.to_string())
                } else {
                    log::error!("Error finding home directory of {username}");
                    continue;
                };
                match home_dir {
                    Some(home_dir) => {
                        let home_file_path = std::path::Path::new(&home_dir);
                        let home_file_path = home_file_path.join(".local/share/flatpak/overrides/");
                        let home_file_path = home_file_path.join(&app_id);

                        log::info!(
                            "Making symlink at {} pointing to {store_file_path}",
                            home_file_path.display()
                        );

                        if let Err(err) =
                            std::os::unix::fs::symlink(&store_file_path, &home_file_path)
                        {
                            error!(
                                "Error creating symlink at {} pointing to {store_file_path}: {err}",
                                home_file_path.display()
                            );
                        } else {
                            continue;
                        };

                        let output = std::process::Command::new("chattr")
                            .arg("+i") // +i flag to set the immutable attribute
                            .arg(&home_file_path)
                            .output();

                        if let Err(err) = output {
                            log::error!(
                                "Error making {} immutable: {err}",
                                home_file_path.display()
                            );
                        }
                    }
                    None => continue,
                }
            }
            /*
            - [x] make file at /var/lib/idwt/store/flatpak_overrides/
            - [x] make symlink at ~/.local/share/flatpak/overrides/{app_id} targetting the file at /var/lib/idwt/store/...
            - [x] make symlink immutable (so user can't delete it)
            */
        }
    }
    // TODO: Cleanup leftover files that are broken symlinks targetting /var/lib/idwt/store/flatpak_overrides/...
    // todo!("cleanup")
    Ok(())
}
