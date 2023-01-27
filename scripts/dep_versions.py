#!/usr/bin/env python3

import subprocess
import functools
import contextlib
import os
import sys
import textwrap

run = functools.partial(subprocess.run, check=True, encoding='utf-8')
eprint = functools.partial(print, file=sys.stderr)

@contextlib.contextmanager
def cd(dir: str):
    currentDir = os.getcwd()
    os.chdir(dir)
    try:
        yield
    finally:
        os.chdir(currentDir)

def main():

    with cd('./ubuntu_22.04/01-deps'):
        run(['make', 'check-deps'])

        with open('versions.mk') as f:
            old_versions = f.read()

        with open('versions_new.mk') as f:
            new_versions = f.read()

        if old_versions == new_versions:
            eprint('No updates!')
            sys.exit(0)
        
        eprint('Updates found!')


    run(['git', 'checkout', 'main'])
    BRANCH_NAME = 'auto-versions'
    run(['git', 'checkout', '-B', BRANCH_NAME])

    commit_new_versions(new_versions)
    raise_pr(BRANCH_NAME)

    exit(42)
    

def commit_new_versions(versions_text):
    MSG = f'Bump dependencies\n\n{versions_text}'
    CHANGELOG_FILE = 'ubuntu_22.04/03-package/changelog'
    VERSIONS_FILE = 'ubuntu_22.04/01-deps/versions.mk'
    with open(VERSIONS_FILE, 'wt') as f:
        f.write(versions_text)
    run(['dch', '-i', '-U', '-c', CHANGELOG_FILE, '-b', MSG], env={**os.environ, 'EMAIL':'akdor1154@noreply.users.github.com'})
    run(['git', 'add', VERSIONS_FILE, CHANGELOG_FILE])
    run(['git', 'commit', '-m', MSG, '--', VERSIONS_FILE, CHANGELOG_FILE])

def raise_pr(branch_name: str):
    run(['git', 'push', '-u', 'origin', '--force', f'{branch_name}:{branch_name}'])
    run(['gh', 'pr', 'create', '--fill', '--assignee', 'akdor1154'])

if __name__ == '__main__':
    main()
