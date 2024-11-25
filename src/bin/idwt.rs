use anyhow::{Context, Result};
use clap::Parser;
use clap_verbosity_flag::Verbosity;
use log::{debug, info, warn};
use std::{path::PathBuf, thread, time};

/// Search for a pattern in a file and display the lines that contain it.
#[derive(Parser)]
struct Cli {
    /// The pattern to look for
    pattern: String,
    /// The path to the file to read
    path: PathBuf,

    #[command(flatten)]
    verbose: Verbosity,
}

fn main() -> Result<()> {
    env_logger::init();
    let cli = Cli::parse();

    warn!("war");
    info!("inf");
    debug!("deb");

    let content = std::fs::read_to_string(&cli.path)
        .with_context(|| format!("could not read file `{}`", &cli.path.display()))?;

    idwt::find_matches(&content, &cli.pattern, &mut std::io::stdout());

    let pb = indicatif::ProgressBar::new(100);
    for _ in 0..100 {
        thread::sleep(time::Duration::from_millis(100));
        pb.inc(1);
    }
    pb.finish_with_message("done");

    Ok(())
}
