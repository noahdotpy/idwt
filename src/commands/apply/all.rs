use anyhow::{anyhow, Result};
use log::error;

pub fn apply_all() -> Result<()> {
    let result = karen::escalate_if_needed();
    if let Err(error) = result {
        error!("Error escalating privileges");
        return Err(anyhow!(error.to_string()));
    }
    crate::commands::apply::block_networking::apply_block_networking()?;
    crate::commands::apply::revoke_admin::apply_revoke_admin()?;
    crate::commands::apply::block_flatpaks::apply_block_flatpaks()?;
    Ok(())
}
