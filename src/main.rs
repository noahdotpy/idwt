use anyhow::Result;
use clap::Parser;
use idwt::commands::run_command;
use idwt::commands::Commands;

#[derive(Debug, Parser)]
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
    env_logger::Builder::new()
        .filter_level(cli.verbose.log_level_filter())
        .init();
    run_command(cli.command)
}
