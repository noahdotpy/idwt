use anyhow::anyhow;
use anyhow::Result;
use log::error;
use std::os::unix::ffi::OsStrExt;
use std::{ffi::OsStr, fs};

/*
This module should create symlinks in `$HOME/.local/share/flatpak/overrides`
(or $XDG_STATE_DIR or something liek that) that target files at
`/var/lib/idwt/store/`. These files at `/var/lib/idwt/store/` will have
configuration that disables the flatpak's access to the x11 and wayland socket,
and blocks internet.

After this module creates all the files it should then delete all the files
in `$HOME/.local/share/flatpak/overrides` that are targetting a non-existent file.
This is often called a broken symlink.

# To get the list of flatpaks to block:
    - If `block-by-default = true` then block all flatpaks installed that
      are not explicity allowed.
    - If `block-by-default = false` (default) then only block the flatpaks listed
      as explicity blocked.

List installed flatpaks using commands:

flatpak list --system --columns app --app | lines
sudo -u john flatpak list --system --columns app --app | lines

List installed flatpaks using the .desktop file directories

/var/lib/flatpak/exports/share/applications
/home/john/.local/share/flatpak/exports/share/applications

Only get the files ending in `.desktop` because these are the actual application names.
Then get rid of the `.desktop` so its only the flatpak id.

*/

fn get_installed_flatpaks() -> Result<()> {
    // todo!();
    let system_location = "/var/lib/flatpak/exports/share/applications";
    let files = fs::read_dir("/etc")
        .unwrap()
        .filter_map(Result::ok)
        .filter(|d| d.path().extension() == Some(OsStr::from_bytes(b"conf")))
        .for_each(|f| f.path().to_str().or(None);
    // files
    //     .filter_map(Result::ok)
    //     .filter(|d| d.path().extension() == Some(OsStr::from_bytes(b"conf")))
    //     .for_each(|f| println!("{:?}", f));
    // let system_apps = fs::read_dir("/var/lib/flatpak/exports/share/applications")?

    //     .filter_map(|e| match e {
    //         Ok(out) => {
    //             let extension = out.path().extension();
    //             if extension == Some(OsStr::new("desktop")) {
    //                 Some(out.path())
    //             } else {
    //                 None
    //             }
    //         }
    //         Err(err) => {
    //             error!("Error listing .desktop files in system location");
    //             None
    //         }
    //     })
    //     .collect();
    // println!("{:?}", system);
    Ok(())
    // for entry in WalkDir::new("foo").into_iter().filter_map(|e| e.ok()) {
    //     println!("{}", entry.path().display());
    // }
}

fn get_block_list() -> Result<()> {
    todo!();
}

pub fn apply_block_flatpaks() -> Result<()> {
    let result = karen::escalate_if_needed();
    if let Err(error) = result {
        error!("Error escalating privileges");
        return Err(anyhow!(error.to_string()));
    }
    todo!();
}
