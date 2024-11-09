#!/usr/bin/env nu

# I Don't Want To (IDWT)

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

# TODO: Test this
def is_day_time_in_schedule [
  schedule: record,
  day_time: record<day: string, hour: int, minute: int>
] {
  for day_range in $schedule {
    let days = expand_day_range $day_range
    if not ($day_time.day in $days) {
      continue
    }

    let start_str = $day_range | get start
    let start = {
      hour: ($start_str | split row '-' | get 0),
      minute: ($start_str | split row '-' | get 1)
    }

    let end_str = $day_range | get end
    let end = {
      hour: ($end_str | split row '-' | get 0),
      minute: ($end_str | split row '-' | get 1)
    }

    if $day_time.hour < $start.hour or $day_time.hour > $end.hour {
      continue
    }

    if $day_time.minute < $start.min or $day_time.minute > $end.minute {
      continue
    }

    return true
  }
  
  return false
}