use anyhow::Result;

pub fn apply_all() -> Result<()> {
    crate::commands::apply::block_networking::apply_block_networking()?;
    crate::commands::apply::revoke_admin::apply_revoke_admin()?;
    Ok(())
}
