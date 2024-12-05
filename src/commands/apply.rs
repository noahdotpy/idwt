use clap::Subcommand;

pub mod all;
pub mod block_flatpaks;
pub mod block_networking;
pub mod delayed_edits;
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
    // The apply commands that need to be ran as root
    System(ApplySystemArgs),
}

#[derive(Debug, clap::Args)]
pub struct ApplySystemArgs {
    #[command(subcommand)]
    pub command: ApplySystemCommands,
}

#[derive(Debug, clap::Subcommand)]
pub enum ApplySystemCommands {
    // Run every `apply system` command
    All,

    // Apply configuration from the block-networking module
    BlockNetworking,

    // Apply configuration from the revoke-admin module
    RevokeAdmin,

    // Apply delayed edits that are set to be applied now
    DelayedEdits,
}

/*
WARNING:
Apply commands should always just print errors to logs and
never interfere with the execution of the other apply commands.
*/
