use anyhow::Error;
use figment::{
    providers::{Format, Serialized, Yaml},
    Figment,
};
use serde::{Deserialize, Serialize};

#[derive(Default, Serialize, Deserialize, Debug)]
pub struct Config {
    tightener: Tightener,

    #[serde(rename = "block-sites")]
    block_sites: Vec<String>,

    #[serde(rename = "block-networking")]
    block_networking: bool,

    #[serde(rename = "affected-users")]
    affected_users: Vec<String>,

    #[serde(rename = "revoke-admin")]
    revoke_admin: Vec<String>,

    #[serde(rename = "kill-plasma-windows")]
    kill_plasma_windows: Vec<KillWindow>,

    #[serde(rename = "kill-gnome-windows")]
    kill_gnome_windows: Vec<KillWindow>,

    #[serde(rename = "kill-processes")]
    kill_processes: KillProcesses,

    #[serde(rename = "disconnect-flatpaks")]
    disconnect_flatpaks: DisconnectFlatpaks,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct KillProcesses {
    include: Vec<String>,
    exclude: Vec<String>,

    #[serde(rename = "exclude-shas")]
    exclude_shas: Vec<String>,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct KillWindow {
    description: String,
    title: Option<String>,
    class: Option<String>,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct Tightener {
    delay: i32,

    #[serde(rename = "approved-commands")]
    approved_commands: Vec<String>,

    #[serde(rename = "delay-enabled")]
    delay_enabled: bool,
}

#[derive(Deserialize, Debug, Serialize, Default)]
pub struct DisconnectFlatpaks {
    exclude: Vec<String>,
    include: Vec<String>,

    #[serde(rename = "include-by-default")]
    include_by_default: bool,
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
