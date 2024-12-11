pub fn apply_all() -> anyhow::Result<()> {
    crate::commands::apply::block_networking::apply_block_networking()?;
    crate::commands::apply::revoke_admin::apply_revoke_admin()?;
    crate::commands::apply::block_flatpaks::apply_block_flatpaks()?;
    Ok(())
}
