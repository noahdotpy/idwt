use anyhow::Result;
use apply::{ApplyArgs, ApplyCommands, ApplySystemCommands};
use clap::Subcommand;
use tighten::{TightenArgs, TightenCommands};

pub mod apply;
pub mod get_config;
pub mod tighten;

#[derive(Debug, Subcommand)]
pub enum Commands {
    Apply(ApplyArgs),
    GetConfig,
    Tighten(TightenArgs),
}

pub fn run_command(command: Commands) -> Result<()> {
    match command {
        Commands::GetConfig => get_config::print_config(),
        Commands::Apply(args) => match args.command {
            ApplyCommands::System(args) => match args.command {
                ApplySystemCommands::All => apply::all::all(),
                ApplySystemCommands::RevokeAdmin => apply::revoke_admin::revoke_admin(),
                ApplySystemCommands::BlockNetworking => apply::block_networking::block_networking(),
            },
        },
        Commands::Tighten(args) => match args.command {
            TightenCommands::Patch => todo!(),
            TightenCommands::Edit => todo!(),
        },
    }
}
