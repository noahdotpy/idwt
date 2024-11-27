use serde::{Deserialize, Serialize};

#[derive(Serialize, Deserialize)]
pub struct Config {
    block_networking: bool,
}

impl Default for Config {
    fn default() -> Config {
        Config {
            block_networking: false,
        }
    }
}
