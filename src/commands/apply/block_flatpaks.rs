use anyhow::anyhow;
use anyhow::Result;
use log::error;
use std::path::PathBuf;
use walkdir::WalkDir;

use crate::config::get_config;

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

    let config = get_config();

    let mut user_files: Vec<PathBuf> = vec![];

    for user in config.unwrap().affected_users {
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

    let config = get_config().unwrap();

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
            todo!("block");
            /*
            make file at /var/lib/idwt/store/flatpak_overrides/
            make symlink at ~/.local/share/flatpak/overrides/{app_id} targetting the file at /var/lib/idwt/store/...
            */
            continue;
        }
    }
    // TODO: Cleanup leftover files that are broken symlinks targetting /var/lib/idwt/store/flatpak_overrides/...
    todo!("cleanup")
}
