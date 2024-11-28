use apply::{ApplyArgs, ApplyCommands, ApplySystemCommands};
use clap::Subcommand;

pub mod apply;
pub mod get_config;

#[derive(Debug, Subcommand)]
pub enum Commands {
    Apply(ApplyArgs),
    GetConfig,
}

pub fn run_command(command: Commands) -> Result<(), anyhow::Error> {
    match command {
        Commands::GetConfig => get_config::get_config(),
        Commands::Apply(args) => match args.command {
            ApplyCommands::System(args) => match args.command {
                ApplySystemCommands::All => todo!(),
                ApplySystemCommands::RevokeAdmin => apply::revoke_admin::revoke_admin(),
            },
        },
    }
}
