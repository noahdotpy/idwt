#[derive(Debug, clap::Args)]
pub struct ApplySystemArgs {
    #[command(subcommand)]
    command: ApplySystemCommands,
}

#[derive(Debug, clap::Subcommand)]
enum ApplySystemCommands {
    All,
    BlockFlatpakNetworking,
}
