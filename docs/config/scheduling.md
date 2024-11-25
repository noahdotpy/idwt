# Applying rules based on schedules

<!-- TODO: Make this not just a giant block of text -->

## when

`when` is a tool you can use to schedule rules based on a day of the week and time based approach.

The `when` key is a list of objects that contain `schedule`, `technique` (optional), and `rule`.

### Schedule

- A list of day ranges as the key, with time range (24 hour format) as the value.

Day ranges can also have multiple expressions. This means you can do something like `monday-friday,sunday`. This example selects all days except for Saturday.

Time ranges are applied when the current time is above (or equal) to the time before the dash, but below the time after the dash.

An example time range is `9:00-15:00`

### Merge technique

- `technique` is either `replace` or `append`

`replace` means that any key will be replaced, but lists will not be merged. `append` is the same, but appends lists

The default technique is `append`.

### Rule

Write it as if you were writing the rule in the configuration file at the top level, but in this key instead. An example is below.

### Example

Below is an example of using `when` to block networking on a schedule.

```yml
when:
  - schedule:
      monday: 07:00-18:00 # apply rule on mondays between 7:00 (7am) - 18:00 (6pm)
      tuesday-saturday: 00:00-15:27:50 # apply rule on tuesday, wednesday, thursday between midnight (start of day) and 5pm
      # if time is not specified as time to apply then the rule will not be applied
    technique: replace # replace or append (append - appends lists, replace does not)
    rule:
      block-networking: true
```
