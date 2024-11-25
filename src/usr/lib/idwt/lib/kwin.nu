#!/usr/bin/env nu

# I Don't Want To (IDWT)

export def "kwin_match_type_to_number" [value: string] -> int {
    return (match $value {
        "exact" => 1,
        "substring" => 2,
        "regex" => 3
    })
}
