#!/usr/bin/env nu

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
    not (echo $value | find --regex $regex | is-empty)
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
def "main" [] {
    let config = open ~/src/idwt/dev/etc/idwt/config.yml
    echo "## Applying: kwin-block-windows ##"

    let users_affected = $config | get kwin-block-windows | columns
    # TODO: find a way to cleanup the leftovers of an old IDWT configuration
    for user in $users_affected {
        let file = $"/home/($user)/.config/kwinrulesrc"

        for rule in ($config | get kwin-block-windows | get $user) {
            let group_name = $"idwt-(^date +%s+%N)"
            kwriteconfig --file $file --group $group_name --key Description "Block Window - Automatically managed by IDWT"

            if (is_property_defined $rule class) {
                kwriteconfig --file $file --group $group_name --key wmclass ($rule | get class.value)
                if (is_property_defined ($rule | get class) whole_window_class) and ($rule | get class.whole_window_class) {
                    kwriteconfig --file $file --group $group_name --key wmclasscomplete "true"
                }
                kwriteconfig --file $file --group $group_name --key wmclassmatch (kwin_match_type_to_number ($rule | get class.match_type))
            }
            if (is_property_defined $rule title) {
                kwriteconfig --file $file --group $group_name --key title ($rule | get title.value)
                kwriteconfig --file $file --group $group_name --key titlematch (kwin_match_type_to_number ($rule | get title.match_type))
            }
            if (is_property_defined $rule role) {
                kwriteconfig --file $file --group $group_name --key windowrole ($rule | get role.value)
                kwriteconfig --file $file --group $group_name --key windowrolematch (kwin_match_type_to_number ($rule | get role.match_type))
            }
            
            kwriteconfig --file $file --group $group_name --key minimize true
            kwriteconfig --file $file --group $group_name --key minimizerule 2 # force
            kwriteconfig --file $file --group $group_name --key size 1,1
            kwriteconfig --file $file --group $group_name --key sizerule 2 # force
            kwriteconfig --file $file --group $group_name --key strictgeometryrule 2 # off, don't care about geometry restrictions

            let count = kreadconfig --file $file --group General --key count | into int
            kwriteconfig --file $file --group General --key count ($count + 1)
            let rules = kreadconfig --file $file --group General --key rules
            kwriteconfig --file $file --group General --key rules $"($rules),($group_name)"
        }
    }
}