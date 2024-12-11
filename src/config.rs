use std::collections::HashMap;

use figment::{
    providers::{Format, Serialized, Yaml},
    Figment,
};
use serde::{Deserialize, Serialize};

use crate::constants;

#[derive(Default, Serialize, Deserialize, Debug)]
pub struct Config {
    pub tightener: Tightener,
    pub modules: Modules,

    #[serde(rename = "affected-users")]
    pub affected_users: Vec<String>,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct Modules {
    #[serde(rename = "block-sites")]
    pub block_sites: Vec<String>,

    #[serde(rename = "block-networking")]
    pub block_networking: bool,

    #[serde(rename = "revoke-admin")]
    pub revoke_admin: Vec<String>,

    #[serde(rename = "kill-plasma-windows")]
    pub kill_plasma_windows: Vec<KillWindow>,

    #[serde(rename = "kill-gnome-windows")]
    pub kill_gnome_windows: Vec<KillWindow>,

    #[serde(rename = "kill-processes")]
    pub kill_processes: KillProcesses,

    #[serde(rename = "block-flatpaks")]
    pub block_flatpaks: BlockFlatpaks,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct KillProcesses {
    pub include: Vec<String>,
    pub exclude: Vec<String>,

    #[serde(rename = "exclude-shas")]
    pub exclude_shas: Vec<String>,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct KillWindow {
    pub description: String,
    pub title: Option<String>,
    pub class: Option<String>,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct Tightener {
    #[serde(rename = "other-delays")]
    pub other_delays: HashMap<String, u64>, // `delays: [{regex: delay}]`

    #[serde(rename = "main-delay")]
    pub main_delay: Option<u64>,

    #[serde(rename = "allowed")]
    pub allowed: Vec<String>,

    #[serde(rename = "delay-enabled")]
    pub delay_enabled: bool,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct BlockFlatpaks {
    pub allow: Vec<String>,
    pub block: Vec<String>,

    #[serde(rename = "block-by-default")]
    pub block_by_default: bool,
}

// impl Default for Config {
//     fn default() -> Config {
//         Config {
//             block_networking: false,
//         }
//     }
// }

pub fn get_config() -> anyhow::Result<Config> {
    let config = Figment::from(Serialized::defaults(Config::default()))
        .merge(Yaml::file(constants::ETC_CONFIG))
        .admerge(Yaml::file(constants::USR_CONFIG))
        .extract()?;
    Ok(config)
}
