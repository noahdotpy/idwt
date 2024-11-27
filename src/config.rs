use crate::structs::Config;
use anyhow::Error;
use figment::{
    providers::{Format, Serialized, Yaml},
    Figment,
};

pub fn get_config() -> Result<Config, Error> {
    let config = Figment::from(Serialized::defaults(Config::default()))
        .merge(Yaml::file("/etc/idwt/config.yml"))
        .extract()?;
    Ok(config)
}
