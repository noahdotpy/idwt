use anyhow::Result;

/*
`tighten edit` will make a RON (Rust Object Notation) file at
/var/spool/idwt/tighten-transactions/ and then run `idwt tighten patch`
externally as root user. We will use sudo to run `idwt tighten patch`
because we want any user with group `idwt-tightener` to be able to run the patch program.

We should check if the user has group `idwt-tightener` before doing anything in this function.
*/

pub fn tighten_edit(command: String) -> Result<()> {
    Ok(())
}
