This tool runs a command, but only when no other copy of that command is already running. It takes the path of a lock file, a number of seconds, and the command. If it can create the lock file, it runs the command and deletes the lock file afterwards, passing the command's exit code back to you. If the lock file is already there, another copy holds it, so this copy exits at once and reports success.

A run that crashes or gets killed leaves its lock file behind, and the number of seconds you give is what stops that leftover file from blocking every run after it. Once the file is older than that, the next copy deletes it and takes the lock for itself.

The tool is for anyone whose cron jobs sometimes take longer than the gap between them, such as a backup, a mirror sync, or an index rebuild. Reach for it when a second copy running alongside the first would waste work or trip over itself, and when a skipped run costs you nothing because the next run will pick the work up. A skip exits with a success code, so cron stays quiet about it. If you want to know when a run was skipped, log that from inside the command itself.

The lock file only guards one machine and one filesystem, so reach for a lock in a database or a lock service when several machines share the work. Over a shared network filesystem, the exclusive create this tool relies on cannot be trusted.

The timestamp on the lock file is set when the lock is taken and never updated, so set the timeout longer than your longest run. Otherwise a second copy will read a live run as a dead one and start alongside it. Two copies reaching a stale lock together can also both clear it and both start. Reach for `flock` instead when two copies at once would corrupt something.
