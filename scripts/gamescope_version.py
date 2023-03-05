#!/usr/bin/env python3

import subprocess
import functools
import contextlib
import os
import sys
import textwrap
import json

run = functools.partial(subprocess.run, check=True, encoding='utf-8')
eprint = functools.partial(print, file=sys.stderr)

@functools.wraps(subprocess.run)
def capture(*args, **kwargs):
    kwargs['capture_output']=True
    try:
        return run(*args, **kwargs)
    except subprocess.CalledProcessError as e:
        if e.stdout:
            eprint(e.stdout)
        if e.stderr:
            eprint(e.stderr)
        raise e

@contextlib.contextmanager
def cd(dir: str):
    currentDir = os.getcwd()
    os.chdir(dir)
    try:
        yield
    finally:
        os.chdir(currentDir)

def main():

    run(['git', 'checkout', 'main'])
    run(['git', 'submodule', 'update', '--checkout'])

    with cd('./gamescope'):
        current_tag = run(['git', 'describe', '--tags', 'HEAD'], capture_output=True).stdout.strip()
        tags = run(['git', 'tag', '-l', '--sort=-creatordate'], capture_output=True).stdout.strip().splitlines()
        tags = [t.strip() for t in tags]
        
        try:
            index_current = tags.index(current_tag)
        except ValueError:
            raise Exception('could not find the current tag in the list of tags')

        if index_current == 0:
            eprint('Current tag is the latest tag')
            exit(0)

        index_next = index_current-1
        tag_next = tags[index_next]
        eprint(f'Found new tag: {tag_next}')

        BRANCH_NAME=f'update-gamescope-{tag_next}'

        with cd('../'):
            update_gamescope(tag_next, BRANCH_NAME)
            raise_pr(BRANCH_NAME)
        
        eprint('raised PR to update gamescope')
        exit(42)

def assert_in_root_repo():
    remotes = run(['git', 'remote', '-v'], capture_output=True).stdout.strip()
    if 'akdor1154/gamescope-pkg' not in remotes:
        eprint(f'remotes output:\n{remotes}')
        raise Exception('not in gamescope-pkg repo, aborting.')

def update_gamescope(tag: str, branch_name: str):
    assert_in_root_repo()
    run(['git', 'checkout', '-B', branch_name])
    with cd('./gamescope'):
        run(['git', 'checkout', tag])
    with open('./gamescope.mk', 'wt') as version_file:
        version_file.write(textwrap.dedent(f'''\
            GAMESCOPE_VERSION={tag}
            GAMESCOPE_TAG={tag}
            DEB_RELEASE=1
        '''))
    MSG = f'Bump gamescope to new tag {tag}'
    CHANGELOG_FILE = 'ubuntu_22.04/03-package/changelog'
    run(['dch', '-v', f'{tag}-1', '-c', CHANGELOG_FILE, '-b', MSG], env={**os.environ, 'EMAIL':'akdor1154@noreply.users.github.com'})
    run(['git', 'add', 'gamescope', 'gamescope.mk', CHANGELOG_FILE])
    run(['git', 'commit', '-m', MSG, '--', 'gamescope', 'gamescope.mk', CHANGELOG_FILE])

def raise_pr(branch_name: str):
    try:
        run(['git', 'push', '-u', 'origin', f'{branch_name}:{branch_name}'])
    except subprocess.CalledProcessError as e:
        if e.returncode != 1:
            raise
        if e.stdout: eprint(e.stdout)
        if e.stderr: eprint(e.stderr)
        eprint('Git push failed, is there already a PR/branch for this update?')
        exit(43)
    message = capture(['git', 'show', '-s', '--pretty=format:%s', 'HEAD']).stdout.strip()
    body = capture(['git', 'show', '-s', '--pretty=format:%B', 'HEAD']).stdout.strip()
    respRaw = capture([
        'gh', 'api',
        '--method', 'POST',
        '-H', 'Accept: application/vnd.github+json',
        '/repos/akdor1154/gamescope-pkg/pulls',
        '-f', f'head={branch_name}',
        '-f', f'base=main',
        '-f', f'title={message}',
        '-f', f'body={body}'
    ]).stdout.strip()
    resp = json.loads(respRaw)
    eprint(f'PR created at {resp["url"]}')

if __name__ == '__main__':
    main()
# get current tag

# list tags

# get first tag after current tag

