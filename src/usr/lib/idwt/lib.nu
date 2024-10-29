#!/usr/bin/env nu

# I Don't Want To (IDWT)

export def "kwin_match_type_to_number" [value: string] -> int {
    return (match $value {
        "exact" => 1,
        "substring" => 2,
        "regex" => 3
    })
}

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

# this does not work when trying to find nested properties (eg. kwin-block-windows.john.0.class)
# instead you can use the following example:
# is_property_defined ($config | get kwin-block-windows.john.0) class
export def "is_property_defined" [
    record: record,
    property: string
] -> bool {
    return (not ($record | columns | where $it == $property | is-empty))
}

export def "is_property_populated" [
    record: record
    property: string,
] -> bool {
    if not (is_property_defined $record $property) {
        return false
    }
    return (not ($record | get $property | is-empty))
}
