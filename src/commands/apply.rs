use clap::Subcommand;

pub mod all;
pub mod block_networking;
pub mod revoke_admin;

/*
`apply system block-flatpak-networking`
*/

#[derive(Debug, clap::Args)]
pub struct ApplyArgs {
    #[command(subcommand)]
    pub command: ApplyCommands,
}

#[derive(Debug, Subcommand)]
pub enum ApplyCommands {
    System(ApplySystemArgs),
}

#[derive(Debug, clap::Args)]
pub struct ApplySystemArgs {
    #[command(subcommand)]
    pub command: ApplySystemCommands,
}

#[derive(Debug, clap::Subcommand)]
pub enum ApplySystemCommands {
    All,
    BlockNetworking,
    RevokeAdmin,
}
