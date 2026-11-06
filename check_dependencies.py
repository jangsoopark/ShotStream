"""Validate ShotStream dependencies, allowing only decord's known wheel-tag bug."""

import subprocess
import sys


KNOWN_DECORD_WARNING = "decord 0.6.0 is not supported on this platform"
SUCCESS_MESSAGE = "No broken requirements found."


def main():
    import decord

    print(f"Decord import: OK ({decord.__version__})")

    result = subprocess.run(
        [sys.executable, "-m", "pip", "check"],
        capture_output=True,
        check=False,
        text=True,
    )
    lines = [
        line.strip()
        for line in (result.stdout + "\n" + result.stderr).splitlines()
        if line.strip()
    ]
    unexpected = [
        line
        for line in lines
        if line not in {KNOWN_DECORD_WARNING, SUCCESS_MESSAGE}
    ]
    known_warning_seen = KNOWN_DECORD_WARNING in lines

    if unexpected or (result.returncode != 0 and not known_warning_seen):
        print("Dependency validation failed:", file=sys.stderr)
        for line in lines:
            print(line, file=sys.stderr)
        return 1

    if known_warning_seen:
        print("Ignoring known decord 0.6.0 wheel metadata mismatch.")
    else:
        print("pip check: OK")

    print("Dependency validation: SUCCESS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
