#!/usr/bin/env python3
"""List pods that are not Running (same logic as not-running.sh)."""
import json
import sys


def main() -> int:
    if len(sys.argv) < 2:                      # like ${1:?usage...} in bash
        print(f"usage: {sys.argv[0]} <pods.json>", file=sys.stderr)
        return 1

    with open(sys.argv[1]) as f:               # 'with' closes the file even if an exception happens
        data = json.load(f)                    # parsed into plain dicts and lists, like JSON.parse

    pods = [
        p["metadata"]["name"]
        for p in data["items"]
        if p["status"]["phase"] != "Running"   # list comprehension = filter + map in one expression
    ]

    if not pods:                               # empty list is falsy
        print("all pods are Running")
        return 0

    print(f"not running: {len(pods)}")
    for name in pods:
        print(f"would run: kubectl describe pod {name}")

    reason = data["items"][0]["status"].get("reason", "<none>")   # .get with default, like jq '// empty' + fallback
    print(f"reason of first pod: '{reason}'")
    return 0


if __name__ == "__main__":                     # runs only when executed directly, not when imported as a module
    sys.exit(main())                           # exit code of the process = return value of main()