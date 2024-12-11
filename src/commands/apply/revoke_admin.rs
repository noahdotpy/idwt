use crate::config::get_config;
use log::{error, info};
use std::process::Command;

pub fn apply_revoke_admin() -> anyhow::Result<()> {
    let config = get_config()?;
    let groups_to_remove = vec!["wheel", "sudo"];

    for username in config.revoke_admin {
        if !config.affected_users.contains(&username) {
            log::warn!(
                "{username} is not in affected-users, skipping execution of revoke admin command"
            );
            continue;
        }
        for group in &groups_to_remove {
            let result = Command::new("/usr/bin/gpasswd")
                .arg("-d")
                .arg(&username)
                .arg(group)
                .output();

            let output = match result {
                Ok(out) => out,
                Err(error) => {
                    error!("Error executing gpasswd: {error}");
                    continue;
                }
            };

            if output.status.success() {
                info!("Successfully removed {username} from {group}");
            } else {
                error!(
                    "Error removing {username} from {group}: {}",
                    String::from_utf8_lossy(&output.stderr)
                );
            }
        }
    }
    Ok(())
}
