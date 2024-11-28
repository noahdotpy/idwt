use clap::Subcommand;

pub mod edit;
pub mod patch;

#[derive(Debug, clap::Args)]
pub struct TightenArgs {
    #[command(subcommand)]
    pub command: TightenCommands,
}

#[derive(Debug, Subcommand)]
pub enum TightenCommands {
    Patch,
    Edit { jq_evaluation: String },
}
