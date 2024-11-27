use anyhow::Error;
use figment::{
    providers::{Format, Serialized, Yaml},
    Figment,
};
use serde::{Deserialize, Serialize};

#[derive(Default, Serialize, Deserialize, Debug)]
pub struct Config {
    #[serde(rename = "block-networking")]
    block_networking: bool,
}

// impl Default for Config {
//     fn default() -> Config {
//         Config {
//             block_networking: false,
//         }
//     }
// }

pub fn get_config() -> Result<Config, Error> {
    let config = Figment::from(Serialized::defaults(Config::default()))
        .merge(Yaml::file("/etc/idwt/config.yml"))
        .admerge(Yaml::file("/usr/share/idwt/config.yml"))
        .extract()?;
    Ok(config)
}
