use std::{
    fs,
    ops::Add,
    process::Command,
    time::{Duration, SystemTime, UNIX_EPOCH},
};

use crate::{
    constants,
    state::{get_state, DelayedEdit},
};
use anyhow::{anyhow, Result};
use log::error;
use regex::Regex;

/*
Add the below line to /etc/sudoers.d/allow-idwt:
```
%idwt-tightener ALL=(ALL) NOPASSWD: /usr/bin/idwt edit *
```

The sudoers line above will allow any user with group `idwt-tightener` to
edit the configuration. These users still have to use commands that match
with atleast one of the allowed regexes configured in `.tightener.allow`,
or a delay will be used from `.tightener.delay` (if enabled at `.tightener.delay-enabled)

If there are delays defined in `.tightener.delays` then these will be used to

# Procedure:

Check if command matches any regexes in `.tightener.allow`
*/

fn does_string_match_any_regexes(string: &String, regexes: &Vec<String>) -> Result<bool> {
    for regex_s in regexes {
        let re = Regex::new(regex_s)?;
        match re.is_match(string) {
            true => return Ok(true),
            false => continue,
        }
    }
    Ok(false)
}

pub fn edit(jq_evaluation: String) -> Result<()> {
    let result = karen::escalate_if_needed();
    if let Err(error) = result {
        error!("Error escalating privileges");
        return Err(anyhow!(error.to_string()));
    }

    let config = crate::config::get_config()?;

    if !does_string_match_any_regexes(&jq_evaluation, &config.tightener.allowed)? {
        let delay = &config
            .tightener
            .other_delays
            .iter()
            .find(|rule| {
                // get first key in hashmap that matches with jq_evaluation
                let re = Regex::new(rule.0).unwrap();
                re.is_match(&jq_evaluation)
            })
            // if match was made in other_delays, use that delay
            .and_then(|rule| Some(rule.1))
            // else use the main delay
            .or_else(|| Some(&config.tightener.main_delay))
            .unwrap();

        let time_since_epoch = SystemTime::now().duration_since(UNIX_EPOCH)?;
        let time_to_apply = time_since_epoch.add(Duration::new(delay.to_owned().to_owned(), 0));

        let mut state = get_state()?;
        state.delayed_edits.append(&mut vec![DelayedEdit {
            command: jq_evaluation,
            time_to_apply: time_to_apply.as_secs(),
        }]);

        let json = serde_yaml::to_string(&state)?;
        fs::write(constants::STATE_FILE, json)?;

        return Ok(());
    }

    // do the config file patching
    Command::new("/usr/bin/yq")
        .arg(&jq_evaluation)
        .arg("/etc/idwt/config.yml")
        .arg("--inplace")
        .output()?;
    Ok(())
}
