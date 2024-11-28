use anyhow::Error;
use figment::{
    providers::{Format, Serialized, Yaml},
    Figment,
};
use serde::{Deserialize, Serialize};

#[derive(Default, Serialize, Deserialize, Debug)]
pub struct Config {
    pub tightener: Tightener,

    #[serde(rename = "block-sites")]
    pub block_sites: Vec<String>,

    #[serde(rename = "block-networking")]
    pub block_networking: bool,

    #[serde(rename = "affected-users")]
    pub affected_users: Vec<String>,

    #[serde(rename = "revoke-admin")]
    pub revoke_admin: Vec<String>,

    #[serde(rename = "kill-plasma-windows")]
    pub kill_plasma_windows: Vec<KillWindow>,

    #[serde(rename = "kill-gnome-windows")]
    pub kill_gnome_windows: Vec<KillWindow>,

    #[serde(rename = "kill-processes")]
    pub kill_processes: KillProcesses,

    #[serde(rename = "disconnect-flatpaks")]
    pub disconnect_flatpaks: DisconnectFlatpaks,
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
    pub delay: i32,

    #[serde(rename = "approved-commands")]
    pub approved_commands: Vec<String>,

    #[serde(rename = "delay-enabled")]
    pub delay_enabled: bool,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct DisconnectFlatpaks {
    pub exclude: Vec<String>,
    pub include: Vec<String>,

    #[serde(rename = "include-by-default")]
    pub include_by_default: bool,
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
