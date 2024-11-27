use clap::Subcommand;

pub mod system;

/*
`apply system block-flatpak-networking`
*/

#[derive(Debug, clap::Args)]
pub struct ApplyArgs {
    #[command(subcommand)]
    command: ApplyCommands,
}

#[derive(Debug, Subcommand)]
pub enum ApplyCommands {
    System(system::ApplySystemArgs),
}
