#!/usr/bin/env nu

# I Don't Want To (IDWT)

use ../lib/constants.nu *

use std repeat

def "how_long_until" [date: int] {
  let minute = 60
  let hour = $minute * 60
  let day = $hour * 24
  let week = $day * 7

  let date_now = ^date +%s | into int
  let difference = $date - $date_now

  if $difference > $week {
    let weeks = $difference / $week
    return $"($weeks) weeks"
  } else if $difference > $day {
    let days = $difference / $day
    return $"($days) days"
  } else if $difference > $hour {
    let hours = $difference / $hour
    return $"($hours) hours"
  } else if $difference > $minute {
    let minutes = $difference / $minute
    return $"($minutes) minutes"
  } else {
    return $"($difference) seconds"
  }
}

# List pending rules.
def "main pending list" [] {
  let pending = try { open $pending_file } | default []

  if ($pending | is-empty) {
    print $'No rules waiting to be applied.'
  }

  mut idx = 1
  for rule in $pending {
    let real_time = how_long_until $rule.time_to_apply
    let command = $'['($rule.command | str join "', '")']'

    let padding = " " | repeat ($idx | into string | str length) | str join

    print $'($idx): command: ($command)'
    print $'($padding)  applying in: ($real_time)'
    $idx += 1
  }
}

def "main pending apply" [] {
  let pending = try { open $pending_file } | default []

  for rule in $pending {
    ^$idwt_bin edit ...$rule.command

    let pending = $pending | filter {|el| $el != $rule}
    $pending | to yaml | save -f $pending_file
  }
}
