#!/usr/bin/env python3

import subprocess
import functools
import sys
import dataclasses
from typing import *

run = functools.partial(subprocess.run, check=True, encoding='utf-8')
eprint = functools.partial(print, file=sys.stderr)

def get_available_version(package_name: str, dist_name: str):
    output = run(['apt-cache', 'madison', package_name], capture_output=True).stdout.splitlines()
    matching = [line for line in output if dist_name in line.split(' ') and 'Sources' in line]
    if len(matching) < 1:
        eprint(output)
        raise Exception(f'Package {package_name} not found in {dist_name}!')
    elif len(matching) > 1:
        eprint(output)
        raise Exception(f'Package {package_name} found multiple versions, aborting!')

    name, version, *stuff = map(str.strip, matching[0].split('|'))

    eprint(f'found {package_name}={version}')
    return version

@dataclasses.dataclass(frozen=True)
class Dep:
    dep_name: str
    package_name: str
    dist: str

DEPS: List[Dep] = [
    Dep('WAYLAND_VERSION', 'wayland', 'lunar/main'),
    Dep('LIBDRM_VERSION', 'libdrm', 'lunar/main'),
    Dep('WAYLAND_PROTOCOLS_VERSION', 'wayland-protocols', 'lunar/main'),
    Dep('HWDATA_VERSION', 'hwdata', 'lunar/main'),
    Dep('VULKAN_LOADER_VERSION', 'vulkan-loader', 'lunar/main'),
    Dep('LIBSDL2_VERSION', 'libsdl2', 'lunar/main')
]

for dep in DEPS:
    version = get_available_version(dep.package_name, dep.dist)
    print(f'{dep.dep_name}={version}')
