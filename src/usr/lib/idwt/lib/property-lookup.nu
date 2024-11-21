#!/usr/bin/env nu

# I Don't Want To (IDWT)

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
