import os
import subprocess
import sys
import time


def acquire(path, stale_after):
    while True:
        try:
            fd = os.open(path, os.O_CREAT | os.O_EXCL | os.O_WRONLY, 0o644)
        except FileExistsError:
            try:
                if time.time() - os.path.getmtime(path) < stale_after:
                    return False
                os.unlink(path)
            except FileNotFoundError:
                pass
            continue
        os.close(fd)
        return True


def main(argv):
    path, stale_after, command = argv[1], float(argv[2]), argv[3:]
    if not acquire(path, stale_after):
        return 0
    try:
        return subprocess.call(command)
    finally:
        os.unlink(path)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
