This tool runs a command, but only if no other copy of the command is already running. You give it a lock file path, a timeout in seconds, and the command to run. If it creates the lock file, it runs the command and deletes the lock file when the command finishes. If the lock file already exists and is newer than the timeout, the tool exits straight away with status 0 and runs nothing.

A command that dies hard, killed or cut off by a power loss, leaves its lock file behind. The timeout covers that case. If the lock file is older than the timeout, the tool deletes it and takes the lock itself, so a stale lock blocks the next run for the length of the timeout and no longer.

Reach for this when a scheduler might start a second copy of a job before the first one finishes. Cron and systemd timers both do that, and so does a person who runs a job by hand while the scheduled one is still going. A backup, an indexer or a sync that overlaps with itself can corrupt its own output, and this tool keeps the second copy from starting.

Set the timeout longer than the longest run you expect. The tool stamps the lock file once, when it takes the lock, and nothing refreshes that stamp while the command runs. If the command outlives the timeout, the next copy treats the live lock as stale and starts a second copy of the command, which is what the lock was there to prevent.

Skipping is silent, and it exits 0, so a scheduler records a skipped run as a success. That suits a job where any run does the same work as the next one. If every run has to happen, use a queue instead.

Reach for something else in two other cases. If the second copy has to wait its turn rather than give up, use `flock`, which blocks until the lock frees. If the copies run on separate machines, a lock file on a shared filesystem won't hold, so use a lock service that the machines agree on.
