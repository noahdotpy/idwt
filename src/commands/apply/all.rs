use anyhow::Result;

pub fn apply_all() -> Result<()> {
    crate::commands::apply::block_networking::block_networking()?;
    crate::commands::apply::revoke_admin::revoke_admin()?;
    Ok(())
}
