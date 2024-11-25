#!/usr/bin/env nu

# I Don't Want To (IDWT)

export def does_regex_list_match_list [
    value_list: list<string>
    regex_list: list<string>
] -> bool {
    # {value: regex}
    let regex_matcher = $value_list | enumerate | each {
        |e| {
            $e.item: ($regex_list | get $e.index)
        }
    }

    let match_list = $regex_matcher | each {
        |entry| {
            let key = $entry | columns | get 0
            let value = $entry | values | get 0
            does_regex_match $key $value
        }
    }
    $match_list | uniq | each {
        |entry| {
            if $entry == false {
                return $entry
            }
        }
    }
    return true
}

export def does_regex_match [
    value: string
    regex: string
] -> bool {
    not ($value | find --regex $regex | is-empty)
}

export def regex_matches_with_any [
    value: string,
    regex_list: list<string>,
] -> bool {
    return (not ($regex_list | each {|regex| echo $value | find --regex $regex} | is-empty))
}
