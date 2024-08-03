#!/usr/bin/env nu

# I Don't Want To (IDWT)

export def does_regex_match [
    value: string
    regex: string
] {
    not (echo $value | find --regex $regex | is-empty)
}

export def regex_matches_with_any [
    regex_list: list,
    value: string,
] {
    return (not ($regex_list | each {|regex| echo $value | find --regex $regex} | is-empty))
}

export def "is_property_defined" [
    record: record,
    property: cell-path,
] {
    return (not ($record | columns | where $it == $property | is-empty))
}

export def "is_property_populated" [
    record: record
    property: cell-path,
] {
    if not (is_property_defined $record $property) {
        return false
    }
    return (not ($record | get $property | is-empty))
}