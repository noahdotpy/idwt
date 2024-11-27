use clap::{Parser, Subcommand};
use idwt::commands;

#[derive(Debug, Parser)]
// #[command(name = "git")]
// #[command(about = "A fictional versioning CLI", long_about = None)]
#[clap(version)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Debug, Subcommand)]
enum Commands {
    Apply(commands::apply::ApplyArgs),
}

fn main() {
    let _args = Cli::parse();
}
