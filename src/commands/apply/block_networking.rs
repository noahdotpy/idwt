use std::process::Command;

use crate::config::get_config;
use anyhow::Result;
use log::{error, info};

pub fn apply_block_networking() -> anyhow::Result<()> {
    let config = get_config()?;

    for username in config.affected_users {
        info!("Adding REJECT rule to {username}");
        let result = Command::new("/usr/sbin/iptables")
            .arg("-A")
            .arg("OUTPUT")
            .arg("-m")
            .arg("owner")
            .arg("--uid-owner")
            .arg(&username)
            .arg("-j")
            .arg("REJECT")
            .output();

        let output = match result {
            Ok(out) => out,
            Err(error) => {
                error!("Error adding REJECT rule: {error}");
                continue;
            }
        };

        if output.status.success() {
            info!("Successfully added REJECT rule to {username}");
        } else {
            error!(
                "Error adding REJECT rule {username}: {}",
                String::from_utf8_lossy(&output.stderr)
            );
        }
    }

    Ok(())
}
