pub fn get_config() -> Result<(), anyhow::Error> {
    let config = crate::config::get_config()?;
    let yaml = serde_yaml::to_string(&config).unwrap();
    println!("{yaml}");
    Ok(())
}
