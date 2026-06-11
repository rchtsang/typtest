#!/usr/bin/env python3
import os
import platform
import shutil
import argparse
import tomllib
from pathlib import Path

"""
a local install script for typst packages
"""

def get_pkg_metadata(pkg_dir: Path) -> dict:
    with open(pkg_dir / "typst.toml", 'rb') as f:
        return tomllib.load(f)['package']

def get_default_prefix() -> Path:
    system = platform.system()
    if system == "Linux":
        return Path(os.getenv("XDG_DATA_HOME", "~/.local/share")).expanduser()

    if system == "Darwin":
        return Path("~/Library/Application Support").expanduser()

    if system == "Windows" and (appdata := os.getenv("APPDATA")):
        return Path(appdata)

    assert False, "unsupported system: {}".format(system)

PKG_SOURCE = Path(__file__).parent
PKG_METADATA = get_pkg_metadata(PKG_SOURCE)
DEFAULT_PREFIX = get_default_prefix()

if __name__ == "__main__":
    parser = argparse.ArgumentParser(prog="install.py", description=__doc__)
    parser.add_argument('-n', '--namespace', dest='namespace', type=str,
        default="local",
        help="override typst pacakge namespace (default: `local`)")
    parser.add_argument('--prefix', dest='prefix', type=Path,
        default=DEFAULT_PREFIX,
        help=f"override install prefix (default: {str(DEFAULT_PREFIX)}")
    parser.add_argument('--force', dest='force', action='store_true',
        default=False,
        help="force package reinstall")
    parser.add_argument('--link', dest='link', action='store_true',
        default=False,
        help="install package as symlink to source directory")
    parser.add_argument('-rm', '--remove', dest='remove', action='store_true',
        default=False,
        help="remove installation")
    parser.add_argument('-y', '--yes', dest='yes', action='store_true',
        default=False,
        help="yes to all prompts")

    args = parser.parse_args()

    install_prefix = args.prefix / "typst" / "packages" / args.namespace
    install_loc = (
        install_prefix / PKG_METADATA['name'] / PKG_METADATA['version']
    )

    print("package info:")
    for field, value in PKG_METADATA.items():
        print(f"{field}: {value}")
    print()
    print(f"install prefix: {str(install_prefix)}")

    if not (args.yes or input("continue? (y/N): ").lower().startswith('y')):
        print("aborted.")
        exit(0)

    print(f"package install location: {str(install_loc)}")

    if install_loc.is_dir() or install_loc.is_symlink():
        if not args.remove and not args.force:
            print("package already installed.")
            exit(0)

        print("removing previous installation...")
        if install_loc.is_symlink():
            install_loc.unlink()
        else:
            shutil.rmtree(install_loc)

        if args.remove:
            print(f"removed {PKG_METADATA['name']}")
            exit(0)

    elif args.remove:
        print("package not found.")
        exit(0)

    install_loc.parent.mkdir(parents=True, exist_ok=True)

    if args.link:
        print(f"linking {str(install_loc)} -> {str(PKG_SOURCE)}")
        install_loc.symlink_to(PKG_SOURCE)
    else:
        ignore = shutil.ignore_patterns(
            '.git',
            '.DS_Store',
            '.gitignore',
            '*.py',
        )

        print(f"installing {PKG_METADATA['name']}...")
        shutil.copytree(
            PKG_SOURCE, install_loc, ignore=ignore, dirs_exist_ok=True)

    print(f"installed {PKG_METADATA['name']}")

