#!/usr/bin/env nu

# I Don't Want To (IDWT)

use std *

def "expand_day_range" [day_range: string] {
  let days_of_week = [monday, tuesday, wednesday, thursday, friday, saturday, sunday]

  # make sure that `tuesday-friday,sunday` is allowed
  mut days = []
  for expression in ($day_range | split row ',') {
    let start = $expression | split row '-' | get 0
    let end = $expression | split row '-' | try { get 1 } | default $start
  
    let start_idx = $days_of_week | iter find-index {|e| $e == $start}
    let end_idx = $days_of_week | iter find-index {|e| $e == $end}

    let expanded_range = if $start_idx <= $end_idx {
      # no wrap-around
      $days_of_week | skip $start_idx | take ($end_idx - $start_idx + 1)
    } else {
      [...$days_of_week ...$days_of_week] | skip $start_idx | take ((8 - $start_idx) + $end_idx)
    }

    $days = [...$days ...$expanded_range]
  }

  return ($days | uniq)
}

# day_time:
#   day: day of the week (wednesday, monday, etc.)
#   time: time of day in 24 hours (11:30, 18:51, etc.)
export def is_day_time_in_schedule [
  schedule: record,
  day_time: record<day: string, time: string>
] {
  for day_range in ($schedule | columns) {
    let days = expand_day_range $day_range
    if not ($day_time.day in $days) {
      continue
    }

    let times = $schedule | get $day_range | split row '-'

    let time = ^date +%s --date=($day_time.time)
    let start = ^date +%s --date=($times.0)
    let end = ^date +%s --date=($times.1)

    if $time < $start or $time >= $end {
      continue
    }

    return true
  }
  
  return false
}