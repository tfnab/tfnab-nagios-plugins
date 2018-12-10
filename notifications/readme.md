# notifications

scripts to replace the default notification commands, with improved output, and grouping in your MUA

## Usage

alter the `command_line` in the `commands.cfg` file like so:

```
# 'notify-host-by-email' command definition
define command{
	command_name    notify-host-by-email
	command_line    $USER1$/notify-host-by-email.sh
}

# 'notify-service-by-email' command definition
define command{
	command_name    notify-service-by-email
	command_line    $USER1$/notify-service-by-email.sh
}
```

you need to have the following set in your `nagios.cfg`:

```
enable_environment_macros=1
```

## Requirements

bash scripts

require `/usr/sbin/sendmail` (a binary by that name is included with most MTAs)
