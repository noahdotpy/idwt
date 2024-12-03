use crate::config::get_config;
use anyhow::{anyhow, Result};
use log::{error, info};

pub fn apply_block_networking() -> Result<()> {
    let result = karen::escalate_if_needed();
    if let Err(error) = result {
        error!("Error escalating privileges");
        return Err(anyhow!(error.to_string()));
    }
    let config = get_config()?;
    let iptable = iptables::new(false);
    let iptable = match iptable {
        Ok(out) => out,
        Err(error) => {
            error!("Error getting iptable: {error}");
            return Err(anyhow!(error.to_string()));
        }
    };

    for username in config.affected_users {
        info!("Adding REJECT rule to {username}");
        let rule = format!("-m owner --uid-owner {username} -j REJECT");
        let result = iptable.append_unique("nat", "OUTPUT", &rule);

        if let Err(error) = result {
            error!("Error appending to table");
            return Err(anyhow!(error.to_string()));
        }

        info!("Successfully added REJECT rule to {username}");
    }

    Ok(())
}
