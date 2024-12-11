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
use anyhow::{anyhow, Error, Result};
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

fn does_string_match_any_regexes(string: &str, regexes: &Vec<String>) -> Result<bool> {
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
    let rs = karen::escalate_if_needed();
    if let Err(err) = rs {
        return Err(anyhow!(err.to_string()));
    }

    log::trace!("Getting config");
    let config = crate::config::get_config()?;

    // if string matches any regexes then apply that string and return
    // else if delay-enabled then check for delays and make state file appendation if applicable
    // else then error out saying no matches were foound and no delays were matched

    log::trace!("Checking if the jq_evaluation matches any regexes");
    if does_string_match_any_regexes(&jq_evaluation, &config.tightener.allowed)? {
        log::info!("String matched one of the regexes, applying patch");
        // do the config file patching
        Command::new("/usr/bin/yq")
            .arg(&jq_evaluation)
            .arg("/etc/idwt/config.yml")
            .arg("--inplace")
            .output()?;
        Ok(())
    } else if config.tightener.delay_enabled {
        log::trace!("Iterating through config.tightener.other_delays to get matches");
        let other_delay_match = &config
            .tightener
            .other_delays
            .iter()
            .find(|rule| {
                // get first key in hashmap that matches with jq_evaluation
                let re = Regex::new(rule.0);
                let re = match re {
                    Ok(out) => out,
                    Err(err) => {
                        log::error!("Error occured while parsing regex {}: {err}", rule.0);
                        return false;
                    }
                };
                re.is_match(&jq_evaluation)
            })
            // if found a match in other_delays, use that delay
            .map(|rule| {
                log::debug!("Using delay from other_delays with rule: {:?}", &rule);
                rule.1
            });

        let delay = match other_delay_match {
            Some(o) => Some(o.to_owned().to_owned()),
            None => config.tightener.main_delay,
        };
        if delay.is_none() {
            return Err(anyhow!(
                "Could not find a delay from either an other_delays regex match or main_delay",
            ));
        } else {
            let time_since_epoch = SystemTime::now().duration_since(UNIX_EPOCH)?;
            let time_to_apply = time_since_epoch.add(Duration::new(
                delay.unwrap_or_default().to_owned().to_owned(),
                0,
            ));

            log::trace!("Appending the delayed_edit rule to state file");

            let mut state = get_state()?;
            state.delayed_edits.append(&mut vec![DelayedEdit {
                command: jq_evaluation,
                time_to_apply: time_to_apply.as_secs(),
            }]);

            log::trace!("Turning state into json and writing");

            let json = serde_yaml::to_string(&state)?;
            fs::write(constants::STATE_FILE, json)?;
        }
        // if other_delay_match use that
        // else if main_delay != null use that
        // else error saying no delay can be found
        return Ok(());
    } else {
        Err(Error::msg("No delays found and no matches were found in approved commands list, not applying any patches"))
    }
}
