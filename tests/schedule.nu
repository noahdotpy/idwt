use ../src/usr/lib/idwt/schedule.nu *

use std assert

export def "main test schedule complex" [] {
    let schedule = {
        monday-friday: "07:00-17:00"
    }
    let day_time = {
        day: friday, 
        time: "16:59:59"
    }

    let result = is_day_time_in_schedule $schedule $day_time
    let expected = true
    
    assert ($result == $expected)
}