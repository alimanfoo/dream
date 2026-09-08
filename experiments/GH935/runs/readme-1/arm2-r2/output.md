You give this tool a lock file path, a timeout in seconds, and a command to run. The tool creates the lock file, runs your command, and deletes the lock file once the command finishes. If the lock file is already there, the tool exits straight away and never runs the command at all.

Skipping is the whole point. The tool won't wait for the lock to free up, and it won't queue the run for later.

That suits a job that runs on a schedule, from cron, a systemd timer, or a hook, where a run that overlaps the previous one causes trouble and a run that gets dropped costs nothing. The next tick picks the work up again.

A command that gets killed, or a machine that loses power, leaves the lock file behind with no process holding it. The timeout clears a lock like that. Set the timeout longer than the longest run you expect, because the tool stamps the lock file once and never updates that stamp while the command runs. If your command is still going when the timeout passes, the next copy will delete the lock and start alongside it.

When every run has to happen, reach for something that waits on the lock instead, such as `flock`, or put the work in a queue.

The tool returns whatever your command returned, and returns zero when it skips, so the caller can't tell a skipped run from a successful one. If you need to tell them apart, have the command record its own runs.

One more limit: the tool works on one machine, on a local filesystem, because that's where exclusive file creation is reliable. Two copies that find the same expired lock at the same moment can also both start. So use a real lock service when two copies at once would corrupt data or spend money twice, and use this tool where a double run only wastes effort.
