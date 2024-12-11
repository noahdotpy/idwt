use anyhow::Result;

pub fn print_config() -> anyhow::Result<()> {
    let config = crate::config::get_config()?;
    let yaml = serde_yaml::to_string(&config)?;
    println!("{yaml}");
    Ok(())
}
