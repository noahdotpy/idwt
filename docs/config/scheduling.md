# Applying rules based on schedules

## when

`when` is a tool you can use to schedule rules based on a day of the week and time based approach.

`when` is a list of objects that contain `schedule`, `mode` (optional), and `rule`.

- Schedule: is a list of day ranges as a key and a time range as the value.
  - An example of a day range is `monday-friday: 00:00-13:00`.
  - Day ranges can also have multiple expressions. This means you can do something like `monday-friday,sunday` which means that it selects all days except for Saturday.
  - Time ranges are in 24 hour format, with seconds being optional but supported.
  - Time ranges are applied when the current time is above (or equal to) the first time, but below the second time.
  - A time range example is 9:00-15:00.
- Mode: is a key that is either `replace` or `merge`.
  - Replace means that any key will be replaced, and lists will not be merged.
  - Merge still means that keys will be replaced, but lists will be merged instead.
  - When it applies the rule, it is still deep merging. Meaning that you can override keys in nested objects, such as with block-kwin-windows.
- Rule: is what rule you want to be applied.
  - Write it as if you were writing it in the configuration file at the top level, but in this key instead.

Below is an example of using `when` to block networking on a schedule.

```yml
when:
  - schedule:
      monday: 07:00-18:00 # apply rule on mondays between 7:00 (7am) - 18:00 (6pm)
      tuesday-saturday: 00:00-15:27:50 # apply rule on tuesday, wednesday, thursday between midnight (start of day) and 5pm
      # if time is not specified as time to apply then the rule will not be applied
    mode: replace # replace or merge (merge appends lists, but overrides keys like replace)
    rule:
      block-networking: true
```
