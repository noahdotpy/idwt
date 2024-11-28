use anyhow::Result;

pub fn get_config() -> Result<()> {
    let config = crate::config::get_config()?;
    let yaml = serde_yaml::to_string(&config)?;
    println!("{yaml}");
    Ok(())
}
