"""
Deploy documentation with mike using the version from package.py.

Examples:
    >>> python .scripts/docs/deploy_docs.py [--push] [--set-default]

Options:
    --push          Push changes to remote gh-pages branch
    --set-default   Set this version as the default
"""

# Built-in
import argparse
import re
import subprocess
import sys
from pathlib import Path


def get_version_from_package() -> str:
    """Extract version string from package.py.

    Returns:
        str: Version string (e.g., '18.1.0')
    """
    package_py = Path(__file__).parent.parent.parent / "package.py"

    if not package_py.exists():
        raise FileNotFoundError(f"package.py not found at {package_py}")

    content = package_py.read_text(encoding="utf-8")
    match = re.search(
        r'^version\s*=\s*["\']([^"\']+)["\']', content, re.MULTILINE
    )

    if not match:
        raise ValueError("Could not find version in package.py")

    return match.group(1)


def get_major_minor(version: str) -> str:
    """Extract major.minor from version string (e.g., '18.1.0' -> '18.1').

    Args:
        version (str): Full version string.

    Returns:
        str: Major.minor version string.
    """
    parts = version.split(".")
    if len(parts) >= 2:
        return f"{parts[0]}.{parts[1]}"
    return version


def main():
    parser = argparse.ArgumentParser(
        description="Deploy docs with mike using package.py version"
    )
    parser.add_argument(
        "--push", action="store_true", help="Push changes to remote"
    )
    parser.add_argument(
        "--set-default", action="store_true", help="Set this version as default"
    )
    parser.add_argument(
        "--alias",
        default="latest",
        help="Alias for this version (default: latest)",
    )
    args = parser.parse_args()

    version = get_version_from_package()

    print(f"Package version: {version}")
    print(f"Documentation version: {version}")

    # Build mike deploy command
    cmd = ["mike", "deploy", "--update-aliases", version, args.alias]

    if args.push:
        cmd.append("--push")

    print(f"Running: {' '.join(cmd)}")
    result = subprocess.run(cmd, check=False)

    if result.returncode != 0:
        print("Failed to deploy documentation")
        sys.exit(result.returncode)

    # Set default if requested
    if args.set_default:
        default_cmd = ["mike", "set-default", args.alias]
        if args.push:
            default_cmd.append("--push")

        print(f"Setting default: {' '.join(default_cmd)}")
        subprocess.run(default_cmd, check=False)

    print(f"Documentation deployed as version {version} (alias: {args.alias})")


if __name__ == "__main__":
    main()
