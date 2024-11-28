use anyhow::Result;
use clap::Parser;
use idwt::commands::run_command;
use idwt::commands::Commands;
use log::info;
use log::warn;

#[derive(Debug, Parser)]
// #[command(name = "idwt")]
// #[command(about = "IDWT", long_about = None)]
#[clap(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,

    #[command(flatten)]
    verbose: clap_verbosity_flag::Verbosity,
}

fn main() -> Result<()> {
    let cli = Cli::parse();
    env_logger::init();
    info!("starting up");
    warn!("oops, nothing implemented!");
    run_command(cli.command)
}
