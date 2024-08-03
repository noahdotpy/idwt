#!/usr/bin/env nu

# I Don't Want To (IDWT)

export def group_add [
    user: string,
    group: string,
] {
    usermod -aG $group $user
}

export def group_remove [
    user: string,
    group: string,
] {
    if (groups $user) =~ $group {
        gpasswd -d $user $group
    }
}
