A lock file, a timeout, and a command are what this tool takes. It creates the lock file, runs your command, and removes the file when the command finishes. If the lock file already exists, your command doesn't run at all, and the tool exits with status 0 as though nothing happened.

The timeout is there because a lock file can outlive the run that made it. The tool removes the file even when the command fails, but a killed process or a power cut leaves it behind, and every later run would then skip. So the tool treats a lock file older than the timeout as abandoned, deletes it, and takes the lock itself. The age comes from the time the lock was taken and is never refreshed, so set the timeout longer than the longest run you expect. If you set it shorter, a later run will delete the lock of a run still in progress and start a second copy alongside it.

This is for anyone who runs a command on a schedule or a trigger they don't control, where two copies at once would cause trouble. Cron, a systemd timer, a file watcher, and a webhook all fire again whether or not the last run has finished.

Reach for it when a skipped run costs you nothing, because the next run does the same work anyway. A sync, a backup, a cache refresh, and a queue drain all fit that shape.

Reach for something else in a few cases. If you need the second run to wait rather than skip, use flock without its non-blocking flag. If you need to know a run got skipped, this tool can't tell you, since it exits 0 either way. If the lock file sits on a network filesystem shared between machines, don't trust it. And if flock is available to you, prefer it, because the kernel releases its lock when the process dies and you have no timeout to guess at.
