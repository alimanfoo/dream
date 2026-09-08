This tool runs a command, but only when no other copy of the command is already running. You give it a path for a lock file, a number of seconds, and the command. If the lock file isn't there, the tool creates it, runs your command, deletes the lock file, and exits with whatever status the command returned. If the lock file is already there and was created within the last however many seconds, the tool takes that as a sign that another copy holds the lock, so it skips your command and exits zero. If the lock file is older than that, the tool assumes that the run which made it has died, so it deletes the lock file and takes the lock itself.

It is for people who run scheduled commands on one machine, from cron or from a timer, and who want the whole mechanism to be a page of Python that they can read in a minute. It needs nothing outside the standard library.

Reach for it when a job runs on a fixed schedule, sometimes takes longer than the gap between runs, and gains nothing from a second copy running alongside the first. A backup and a log upload both fit. The overlapping run exits quietly, so cron has nothing to mail you about.

The skipped run is dropped, and nothing queues it or retries it. If every run has to happen, use a queue instead. A skip and a clean success both exit zero, so if you need to tell them apart, you need something else.

The lock file's timestamp is set once, when the lock is taken, and it is never refreshed while your command runs. So set the timeout above the longest run you expect. If you can't put an upper bound on the run time, use `flock`, because the kernel drops the lock when the process dies and there is no timeout to guess.

When a lock does go stale, two runs can both delete it and both take it, so don't rely on this where two copies would corrupt data. The lock is a file on a local disk, so it coordinates one machine. To coordinate several machines, use a lock service.
