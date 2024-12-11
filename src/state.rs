use figment::{
    providers::{Format, Serialized, Yaml},
    Figment,
};
use serde::{Deserialize, Serialize};

use crate::constants;

#[derive(Serialize, Deserialize, Default)]
pub struct State {
    pub delayed_edits: Vec<DelayedEdit>,
}

#[derive(Serialize, Deserialize, Default)]
pub struct DelayedEdit {
    pub command: String,
    pub time_to_apply: u64, // time in seconds (like what you would get from `/usr/bin/date +%s`)
}

pub fn get_state() -> anyhow::Result<State> {
    let state = Figment::from(Serialized::defaults(State::default()))
        .merge(Yaml::file(constants::STATE_FILE))
        .extract()?;
    Ok(state)
}
