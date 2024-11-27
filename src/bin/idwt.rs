use clap::Parser;
use idwt::commands::run_command;
use idwt::commands::Commands;

#[derive(Debug, Parser)]
// #[command(name = "idwt")]
// #[command(about = "IDWT", long_about = None)]
#[clap(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

fn main() -> Result<(), anyhow::Error> {
    let cli = Cli::parse();
    run_command(cli.command)
}
