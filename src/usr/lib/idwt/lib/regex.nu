#!/usr/bin/env nu

# I Don't Want To (IDWT)

export def does_regex_match [
    value: string
    regex: string
] -> bool {
    not ($value | find --regex $regex | is-empty)
}

export def regex_matches_with_any [
    regex_list: list,
    value: string,
] -> bool {
    return (not ($regex_list | each {|regex| echo $value | find --regex $regex} | is-empty))
}
