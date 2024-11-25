use ./schedule.nu *
use ./regex.nu *

def "main" [] {
    print '-- Testing: schedule complex --'
    main test schedule complex
    print '-- Testing: regex does_regex_list_match_list --'
    main test schedule complex
}
