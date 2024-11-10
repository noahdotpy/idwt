# Automatically killing processes

## process-killing.block

`process-killing.block` uses regular expressions.

- This command is dangerous, as it can kill any process, whether it is vital to the system stability or not. Be careful.
- Although it is still potentially dangerous, there is a safety measure in place that checks if the command was started by a user in the `affected-users` key.
- They do not necessarily have to start with `^` and end with `$`.
- When building regular expressions make sure to use the Rust flavour on websites like [regex101.com](https://regex101.com/).

The default value for this key is an empty list (`[]`).

Below is an example of using a regular expression to block all processes originating from John's user directory.

```yml
process-killing:
  block:
    - ^/home/john/.*$
```

## TODO: process-killing.allow

## TODO: process-killing.allow-shas
